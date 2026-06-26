h4.mt-3 = "#{state.capitalize} (#{job_runs.size})"

- if job_runs.empty?
  p.text-muted No jobs.
- else
  .table-responsive
    table.table.table-sm.table-striped
      thead
        tr
          th ID
          th Type
          th Retries
          th Enqueued
          th Started
          th Finished
      tbody
        - job_runs.each do |job_run|
          tr
            td = job_run.id
            - if job_run.found?
              td = job_run.type
              td = job_run.retry_count
              td = job_run.enqueue_time.by_example("January 2, 2006 @ 15:04")
              td = job_run.started_at.try(&.by_example("January 2, 2006 @ 15:04"))
              td = job_run.finished_at.try(&.by_example("January 2, 2006 @ 15:04"))
            - else
              td colspan="5" Missing metadata
