private def mosquito_job_run_json(job_run : Mosquito::Api::JobRun)
  found = job_run.found?

  {
    "id"          => job_run.id,
    "found"       => found,
    "type"        => found ? job_run.type : nil,
    "retry_count" => found ? job_run.retry_count : nil,
    "enqueue_time" => found ? job_run.enqueue_time.by_example("January 2, 2006 @ 15:04") : nil,
    "started_at"  => found ? job_run.started_at.try(&.by_example("January 2, 2006 @ 15:04")) : nil,
    "finished_at" => found ? job_run.finished_at.try(&.by_example("January 2, 2006 @ 15:04")) : nil,
  }
end

private def mosquito_queue_json(queue : Mosquito::Api::Queue)
  sizes = queue.size_details

  {
    "name"   => queue.name,
    "paused" => queue.paused?,
    "sizes"  => {
      "waiting"   => sizes["waiting"],
      "scheduled" => sizes["scheduled"],
      "pending"   => sizes["pending"],
      "dead"      => sizes["dead"],
    },
  }
end

private def mosquito_queue_details_json(queue : Mosquito::Api::Queue)
  {
    "queue" => mosquito_queue_json(queue),
    "jobs"  => {
      "waiting"   => queue.waiting_job_runs.map { |job_run| mosquito_job_run_json(job_run) },
      "scheduled" => queue.scheduled_job_runs.map { |job_run| mosquito_job_run_json(job_run) },
      "pending"   => queue.pending_job_runs.map { |job_run| mosquito_job_run_json(job_run) },
      "dead"      => queue.dead_job_runs.map { |job_run| mosquito_job_run_json(job_run) },
    },
  }
end

router = Kemal::Router.new

router.namespace "/admin" do
  before do |env|
    unless (current_user = current_user(env)) && current_user.admin?
      halt env, status_code: 403, response: "Forbidden"
    end
  end

  get "/" do |env|
    request_context = env.get("request_context").as(RequestContext)
    request_context.page_title = "Admin:"
    env.set "request_context", request_context

    render "src/views/admin/index.slang", "src/views/layouts/layout.slang"
  end

  get "/admins" do |env|
    page = env.params.query["page"]? || ""
    page = page.to_i? || 1
    per_page = 20
    offset = (page - 1) * per_page

    raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

    admin_query = Admin.query.order_by(created_at: :desc)

    total_count = admin_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/admins&page=#{page}"
    ).to_s

    admins = admin_query.limit(per_page).offset(offset)

    set_request_context(env) do
      request_context.page_title = "Admin: Site Admins"
    end

    render "src/views/admin/admins/index.slang", "src/views/layouts/layout.slang"
  end

  namespace "/repositories" do
    get "/new" do |env|
      set_request_context(env) do
        request_context.page_title = "Admin: Add new repository"
      end

      render "src/views/admin/repositories/new.slang", "src/views/layouts/layout.slang"
    end

    post "/" do |env|
      url = env.params.body["repository[url]"].as(String)

      if repository = Helpers.sync_repository_by_url(url)
        env.flash["notice"] = "Repository was successfully added."

        env.redirect(repository.decorate.show_path)
      else
        env.flash["notice"] = "Something went wrong."

        env.redirect("/admin/repositories/new")
      end
    end

    post "/:id/sync" do |env|
      id = env.params.url["id"]

      if repository = Repository.find(id)
        repository.resync!

        env.flash["notice"] = "Repository was successfully synced."

        env.json({
          "status" => "success",
          "data"   => {
            "redirect_url" => "/#{repository.provider}/#{repository.user.login}/#{repository.name}",
          },
        })
      end
    end

    post "/:id/show" do |env|
      id = env.params.url["id"]

      if repository = Repository.find(id)
        repository.update(ignore: false)

        env.flash["notice"] = "Repository was successfully shown."

        env.json({
          "status" => "success",
          "data"   => {
            "redirect_url" => "/#{repository.provider}/#{repository.user.login}/#{repository.name}",
          },
        })
      end
    end

    post "/:id/hide" do |env|
      id = env.params.url["id"]

      if repository = Repository.find(id)
        repository.update(ignore: true)

        env.flash["notice"] = "Repository was successfully hidden."

        env.json({
          "status" => "success",
          "data"   => {
            "redirect_url" => "/#{repository.provider}/#{repository.user.login}/#{repository.name}",
          },
        })
      end
    end

    delete "/:id" do |env|
      id = env.params.url["id"]

      if repository = Repository.find(id)
        repository.delete

        env.flash["notice"] = "Repository was successfully destroyed."

        env.json({
          "status" => "success",
          "data"   => {
            "redirect_url" => "/",
          },
        })
      end
    end
  end

  get "/hidden_users" do |env|
    page = env.params.query["page"]? || ""
    page = page.to_i? || 1
    per_page = 20
    offset = (page - 1) * per_page

    raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

    users_query =
      User
        .query
        .join(:repositories)
        .where { users.ignore.true? }
        .select(
          "users.*",
          "COUNT(repositories.*) AS repositories_count",
        )
        .group_by("users.id")

    total_count = users_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/hidden_users&page=#{page}"
    ).to_s

    users = users_query.limit(per_page).offset(offset)

    set_request_context(env) do
      request_context.page_title = "Admin: Hidden Users"
    end

    render "src/views/admin/hidden_users/index.slang", "src/views/layouts/layout.slang"
  end

  get "/hidden_repositories" do |env|
    page = env.params.query["page"]? || ""
    page = page.to_i? || 1
    per_page = 20
    offset = (page - 1) * per_page

    raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

    repositories_query =
      Repository
        .query
        .with_user
        .where { repositories.ignore.true? }
        .order_by(stars_count: :desc)

    total_count = repositories_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/hidden_repositories&page=#{page}"
    ).to_s

    repositories = repositories_query.limit(per_page).offset(offset)

    set_request_context(env) do
      request_context.page_title = "Admin: Hidden Repositories"
    end

    render "src/views/admin/hidden_repositories/index.slang", "src/views/layouts/layout.slang"
  end

  get "/active_users" do |env|
    keys = ACTIVE_USERS_CACHE.keys

    set_request_context(env) do
      request_context.page_title = "Admin: Active Users"
    end

    render "src/views/admin/active_users/index.slang", "src/views/layouts/layout.slang"
  end

  get "/mosquito" do |env|
    queues = Mosquito::Api::Queue.all.sort

    set_request_context(env) do
      request_context.page_title = "Admin: Mosquito"
    end

    render "src/views/admin/mosquito/index.slang", "src/views/layouts/layout.slang"
  end

  get "/mosquito.json" do |env|
    queues = Mosquito::Api::Queue.all.sort

    env.json({
      "queues" => queues.map { |queue| mosquito_queue_json(queue) },
    })
  end

  get "/mosquito/queues/:name" do |env|
    queue_name = env.params.url["name"]
    queue = Mosquito::Api::Queue.new(queue_name)

    set_request_context(env) do
      request_context.page_title = "Admin: Mosquito: #{queue_name}"
    end

    render "src/views/admin/mosquito/show.slang", "src/views/layouts/layout.slang"
  end

  get "/mosquito/queues/:name.json" do |env|
    queue_name = env.params.url["name"]
    queue = Mosquito::Api::Queue.new(queue_name)

    env.json(mosquito_queue_details_json(queue))
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
    Mosquito.backend.connection.not_nil!.lrem(
      Mosquito.backend.build_key("dead", queue_name),
      0,
      id
    )

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

  namespace "/users" do
    post "/:id/sync" do |env|
      id = env.params.url["id"]

      if user = User.find(id)
        user.resync!

        env.flash["notice"] = "User was successfully synced."

        env.json({
          "status" => "success",
          "data"   => {
            "redirect_url" => "/#{user.provider}/#{user.login}",
          },
        })
      end
    end

    delete "/:id" do |env|
      id = env.params.url["id"]

      if user = User.find(id)
        user.delete

        env.flash["notice"] = "User was successfully destroyed."

        env.json({
          "status" => "success",
          "data"   => {
            "redirect_url" => "/",
          },
        })
      end
    end

    post "/:id/show" do |env|
      id = env.params.url["id"]

      if user = User.find(id)
        user.update(ignore: false)

        env.flash["notice"] = "User was successfully shown."

        env.json({
          "status" => "success",
          "data"   => {
            "redirect_url" => "/#{user.provider}/#{user.login}",
          },
        })
      end
    end

    post "/:id/hide" do |env|
      id = env.params.url["id"]

      if user = User.find(id)
        user.update(ignore: true)

        env.flash["notice"] = "User was successfully hidden."

        env.json({
          "status" => "success",
          "data"   => {
            "redirect_url" => "/#{user.provider}/#{user.login}",
          },
        })
      end
    end
  end
end

mount router
