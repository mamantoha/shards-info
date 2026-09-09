private def mosquito_job_run_json(job_run : Mosquito::Api::JobRun)
  found = job_run.found?

  {
    "id"                 => job_run.id,
    "found"              => found,
    "type"               => found ? job_run.type : nil,
    "retry_count"        => found ? job_run.retry_count : nil,
    "enqueue_time"       => found ? job_run.enqueue_time.by_example("January 2, 2006 @ 15:04") : nil,
    "started_at"         => found ? job_run.started_at.try(&.by_example("January 2, 2006 @ 15:04")) : nil,
    "finished_at"        => found ? job_run.finished_at.try(&.by_example("January 2, 2006 @ 15:04")) : nil,
    "failed_at"          => found ? job_run.failed_at.try(&.by_example("January 2, 2006 @ 15:04")) : nil,
    "error_class"        => found ? job_run.error_class : nil,
    "error_message"      => found ? job_run.error_message : nil,
    "runtime_parameters" => found ? job_run.runtime_parameters : nil,
  }
end

private def mosquito_metric_json(summary : MosquitoMetric::Summary)
  {
    "processed"          => summary.processed,
    "succeeded"          => summary.succeeded,
    "failed"             => summary.failed,
    "preempted"          => summary.preempted,
    "aborted"            => summary.aborted,
    "runtime_ms"         => summary.runtime_ms,
    "average_runtime_ms" => summary.average_runtime_ms.round(2),
  }
end

private def mosquito_queue_json(
  queue : Mosquito::Api::Queue,
  metrics : MosquitoMetric::Summary? = nil,
)
  sizes = queue.size_details

  {
    "name"    => queue.name,
    "paused"  => queue.paused?,
    "metrics" => metrics.try { |summary| mosquito_metric_json(summary) },
    "sizes"   => {
      "waiting"   => sizes["waiting"],
      "scheduled" => sizes["scheduled"],
      "pending"   => sizes["pending"],
      "dead"      => sizes["dead"],
    },
  }
end

private def mosquito_queue_details_json(
  queue : Mosquito::Api::Queue,
  metrics : MosquitoMetric::Summary,
)
  {
    "queue"   => mosquito_queue_json(queue),
    "metrics" => mosquito_metric_json(metrics),
    "jobs"    => {
      "waiting"   => queue.waiting_job_runs.map { |job_run| mosquito_job_run_json(job_run) },
      "scheduled" => queue.scheduled_job_runs.map { |job_run| mosquito_job_run_json(job_run) },
      "pending"   => queue.pending_job_runs.map { |job_run| mosquito_job_run_json(job_run) },
      "dead"      => queue.dead_job_runs.map { |job_run| mosquito_job_run_json(job_run) },
    },
  }
end

private def mosquito_executor_json(executor : Mosquito::Api::Executor)
  {
    "instance_id"       => executor.instance_id,
    "heartbeat"         => executor.heartbeat.try(&.by_example("January 2, 2006 @ 15:04")),
    "current_job"       => executor.current_job,
    "current_job_queue" => executor.current_job_queue,
  }
end

private def mosquito_overseer_json(overseer : Mosquito::Api::Overseer)
  {
    "instance_id"    => overseer.instance_id,
    "last_heartbeat" => overseer.last_heartbeat.try(&.by_example("January 2, 2006 @ 15:04")),
    "executors"      => overseer.executors.map { |executor| mosquito_executor_json(executor) },
  }
end

private def mosquito_live_counts(queue_sizes : Array(Hash(String, Int64)))
  counts = {
    waiting:   0_i64,
    scheduled: 0_i64,
    pending:   0_i64,
    dead:      0_i64,
  }

  queue_sizes.each do |sizes|
    counts = {
      waiting:   counts[:waiting] + sizes["waiting"],
      scheduled: counts[:scheduled] + sizes["scheduled"],
      pending:   counts[:pending] + sizes["pending"],
      dead:      counts[:dead] + sizes["dead"],
    }
  end

  counts
end

router = Kemal::Router.new

router.namespace "/admin" do
  before do |env|
    unless current_admin?(env)
      halt env, status_code: 403, response: "Forbidden"
    end
  end

  get "/mosquito" do |env|
    queues = Mosquito::Api::Queue.all.sort
    queue_rows = queues.map { |queue| {queue: queue, sizes: queue.size_details} }
    live_counts = mosquito_live_counts(queue_rows.map(&.[:sizes]))
    metrics_summary = MosquitoMetric.summary
    metrics_by_queue = MosquitoMetric.summaries_by_queue

    set_request_context(env) do
      request_context.page_title = "Admin: Mosquito"
    end

    render "src/views/admin/mosquito/index.slang", "src/views/layouts/layout.slang"
  end

  get "/mosquito.json" do |env|
    queues = Mosquito::Api::Queue.all.sort
    metrics_summary = MosquitoMetric.summary
    metrics_by_queue = MosquitoMetric.summaries_by_queue

    env.json({
      "metrics" => mosquito_metric_json(metrics_summary),
      "queues"  => queues.map do |queue|
        mosquito_queue_json(queue, metrics_by_queue[queue.name]?)
      end,
    })
  end

  get "/mosquito/metrics.json" do |env|
    days = env.params.query["days"]?.try(&.to_i?) || 7
    days = 7 unless {7, 30, 90, 180}.includes?(days)
    queue_name = env.params.query["queue"]?

    env.json({
      "history" => MosquitoMetric.history(days, queue_name).map do |point|
        {
          "day"       => point.day,
          "processed" => point.processed,
          "failed"    => point.failed,
        }
      end,
    })
  end

  get "/mosquito/workers" do |env|
    overseers = Mosquito::Api::Overseer.all

    set_request_context(env) do
      request_context.page_title = "Admin: Mosquito: Workers"
    end

    render "src/views/admin/mosquito/workers.slang", "src/views/layouts/layout.slang"
  end

  get "/mosquito/workers.json" do |env|
    overseers = Mosquito::Api::Overseer.all

    env.json({
      "workers" => overseers.map { |overseer| mosquito_overseer_json(overseer) },
    })
  end

  get "/mosquito/queues/:name/data" do |env|
    queue_name = env.params.url["name"]
    queue = Mosquito::Api::Queue.new(queue_name)
    metrics_summary = MosquitoMetric.summary(queue_name)

    env.json(mosquito_queue_details_json(queue, metrics_summary))
  end

  get "/mosquito/queues/:name" do |env|
    queue_name = env.params.url["name"]
    queue = Mosquito::Api::Queue.new(queue_name)
    sizes = queue.size_details
    live_counts = mosquito_live_counts([sizes])
    metrics_summary = MosquitoMetric.summary(queue_name)

    set_request_context(env) do
      request_context.page_title = "Admin: Mosquito: #{queue_name}"
    end

    render "src/views/admin/mosquito/show.slang", "src/views/layouts/layout.slang"
  end

  post "/mosquito/dead_jobs" do |env|
    queue_name = env.params.body["queue[name]"].as(String)
    queue = Mosquito::Api::Queue.new(queue_name)
    dead_job_runs = queue.dead_job_runs

    dead_job_runs.each do |job_run|
      Mosquito.backend.delete(Mosquito::JobRun.config_key(job_run.id))
    end

    Mosquito.backend.delete(Mosquito.backend.build_key("dead", queue_name))

    env.flash["notice"] = "Deleted #{dead_job_runs.size} dead jobs from #{queue_name}."
    env.redirect("/admin/mosquito")
  end

  post "/mosquito/dead_jobs/:id" do |env|
    id = env.params.url["id"]
    queue_name = env.params.body["queue[name]"].as(String)

    Mosquito.backend.delete(Mosquito::JobRun.config_key(id))
    if connection = Mosquito.backend.connection
      connection.lrem(
        Mosquito.backend.build_key("dead", queue_name),
        0,
        id
      )
    end

    if env.request.headers["X-Requested-With"]? == "XMLHttpRequest"
      env.json({
        "status" => "success",
        "data"   => {
          "id"         => id,
          "queue_name" => queue_name,
        },
      })
    else
      env.flash["notice"] = "Deleted dead job #{id} from #{queue_name}."
      env.redirect("/admin/mosquito")
    end
  end

  post "/mosquito/queues/:name/pause" do |env|
    queue_name = env.params.url["name"]
    Mosquito::Queue.new(queue_name).pause

    if env.request.headers["X-Requested-With"]? == "XMLHttpRequest"
      env.json({
        "status" => "success",
        "data"   => {
          "queue" => mosquito_queue_json(Mosquito::Api::Queue.new(queue_name)),
        },
      })
    else
      env.flash["notice"] = "Paused #{queue_name}."
      env.redirect(env.request.headers["Referer"]? || "/admin/mosquito")
    end
  end

  post "/mosquito/queues/:name/resume" do |env|
    queue_name = env.params.url["name"]
    Mosquito::Queue.new(queue_name).resume

    if env.request.headers["X-Requested-With"]? == "XMLHttpRequest"
      env.json({
        "status" => "success",
        "data"   => {
          "queue" => mosquito_queue_json(Mosquito::Api::Queue.new(queue_name)),
        },
      })
    else
      env.flash["notice"] = "Resumed #{queue_name}."
      env.redirect(env.request.headers["Referer"]? || "/admin/mosquito")
    end
  end
end

mount router
