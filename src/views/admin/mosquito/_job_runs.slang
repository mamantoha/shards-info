h4.mt-3
  = "#{state.capitalize} ("
  span class="#{state == "dead" ? "js-mosquito-dead-section-count" : ""}" data-queue-name="#{queue.name}" = job_runs.size
  = ")"

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
        th Parameters
        th
    tbody.js-mosquito-jobs data-queue-name="#{queue.name}" data-job-state="#{state}"
      - if job_runs.empty?
        tr.js-mosquito-empty-row
          td.text-muted colspan="7" No jobs.
      - else
        - job_runs.each do |job_run|
          tr.js-mosquito-job-row data-queue-name="#{queue.name}" data-job-state="#{state}" data-job-id="#{job_run.id}"
            td = job_run.id
            - if job_run.found?
              td = job_run.type
              td = job_run.retry_count
              td = job_run.enqueue_time.by_example("January 2, 2006 @ 15:04")
              td = job_run.started_at.try(&.by_example("January 2, 2006 @ 15:04"))
              td = job_run.finished_at.try(&.by_example("January 2, 2006 @ 15:04"))
              td
                - job_run.runtime_parameters.each do |key, value|
                  div
                    code = "#{key}=#{value}"
            - else
              td colspan="6" Missing metadata
            td
              - if state == "dead"
                form.js-delete-dead-job action="/admin/mosquito/dead_jobs/#{job_run.id}" method="post"
                  input type="hidden" name="queue[name]" value="#{queue.name}"
                  button.btn.btn-sm.btn-danger type="submit" Delete
