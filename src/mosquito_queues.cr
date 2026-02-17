require "../config/config"

Mosquito::Api::Queue.all.each do |api_queue|
  puts "Queue: #{api_queue.name}"

  {
    waiting:   api_queue.waiting_job_runs,
    scheduled: api_queue.scheduled_job_runs,
    pending:   api_queue.pending_job_runs,
    dead:      api_queue.dead_job_runs,
  }.each do |state, job_runs|
    puts "  #{state} (#{job_runs.size})"
    job_runs.each do |jr|
      # queue = Mosquito::Queue.new(api_queue.name)
      # queue.flush

      if jr.found?
        puts "    - #{jr.id} type=#{jr.type} retries=#{jr.retry_count} (enqueued_at=#{jr.enqueue_time})"
      end
    end
  end
end
