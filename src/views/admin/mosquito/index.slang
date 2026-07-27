.container.js-mosquito-content
  div.mt-3
    nav aria-label="breadcrumb"
      ol.breadcrumb
        li.breadcrumb-item
          a href="/admin" Admin
        li.breadcrumb-item.active aria-current="page" Mosquito

  .d-flex.align-items-center.justify-content-between
    h2 Mosquito
    .d-flex.gap-2
      a.btn.btn-sm.btn-outline-secondary href="/admin/mosquito/workers" Workers
      button.btn.btn-sm.btn-outline-secondary.js-live-poll type="button" data-interval="5000" data-url="/admin/mosquito.json" Live Poll

  - metrics_history_url = "/admin/mosquito/metrics.json"
  == render "src/views/admin/mosquito/_metrics_summary.slang"

  - if queue_rows.empty?
    p No queues found.
  - else
    .table-responsive
      table.table.table-striped
        thead
          tr
            th Queue
            th Waiting
            th Scheduled
            th Pending
            th Dead
            th Processed
            th Failed
            th Average runtime
            th
            th
        tbody.js-mosquito-queues
          - queue_rows.each do |row|
            - queue = row[:queue]
            - sizes = row[:sizes]
            - metrics = metrics_by_queue[queue.name]?
            tr.js-mosquito-queue-row data-queue-name="#{queue.name}"
              td
                a href="/admin/mosquito/queues/#{queue.name}" = queue.name
              td.js-mosquito-waiting-count = sizes["waiting"]
              td.js-mosquito-scheduled-count = sizes["scheduled"]
              td.js-mosquito-pending-count = sizes["pending"]
              td.js-mosquito-dead-count data-queue-name="#{queue.name}" = sizes["dead"]
              - processed = metrics.try(&.processed) || 0
              - failed = metrics.try(&.failed) || 0
              - average_runtime_ms = metrics.try(&.average_runtime_ms) || 0.0
              td.js-mosquito-metric-number.js-mosquito-processed-count data-value=processed = processed
              td.js-mosquito-metric-number.js-mosquito-failed-count data-value=failed = failed
              td.js-mosquito-runtime.js-mosquito-average-runtime data-milliseconds=average_runtime_ms = "#{average_runtime_ms.round(2)} ms"
              td.js-mosquito-pause
                - if queue.paused?
                  form.js-mosquito-queue-action action="/admin/mosquito/queues/#{queue.name}/resume" method="post"
                    button.btn.btn-sm.btn-secondary type="submit" Resume
                - else
                  form.js-mosquito-queue-action action="/admin/mosquito/queues/#{queue.name}/pause" method="post"
                    button.btn.btn-sm.btn-warning type="submit" Pause
              td.js-mosquito-delete-dead
                - if sizes["dead"] > 0
                  form action="/admin/mosquito/dead_jobs" method="post"
                    input type="hidden" name="queue[name]" value="#{queue.name}"
                    button.btn.btn-sm.btn-danger type="submit" Delete dead jobs
