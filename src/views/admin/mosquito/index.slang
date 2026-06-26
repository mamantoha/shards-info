.container.js-mosquito-content
  div.mt-3
    nav aria-label="breadcrumb"
      ol.breadcrumb
        li.breadcrumb-item
          a href="/admin" Admin
        li.breadcrumb-item.active aria-current="page" Mosquito

  .d-flex.align-items-center.justify-content-between
    h2 Mosquito
    button.btn.btn-sm.btn-outline-secondary.js-live-poll type="button" data-interval="5000" data-url="/admin/mosquito.json" Live Poll

  - if queues.empty?
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
            th
            th
        tbody.js-mosquito-queues
          - queues.each do |queue|
            - sizes = queue.size_details
            tr.js-mosquito-queue-row data-queue-name="#{queue.name}"
              td
                a href="/admin/mosquito/queues/#{queue.name}" = queue.name
              td.js-mosquito-waiting-count = sizes["waiting"]
              td.js-mosquito-scheduled-count = sizes["scheduled"]
              td.js-mosquito-pending-count = sizes["pending"]
              td.js-mosquito-dead-count data-queue-name="#{queue.name}" = sizes["dead"]
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
