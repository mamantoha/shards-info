.container.js-mosquito-content
  div.mt-3
    nav aria-label="breadcrumb"
      ol.breadcrumb
        li.breadcrumb-item
          a href="/admin" Admin
        li.breadcrumb-item
          a href="/admin/mosquito" Mosquito
        li.breadcrumb-item.active aria-current="page" = queue.name

  .d-flex.align-items-center.justify-content-between
    h2 = queue.name
    button.btn.btn-sm.btn-outline-secondary.js-live-poll type="button" data-interval="5000" Live Poll

  - sizes = queue.size_details
  .table-responsive
    table.table.table-striped
      thead
        tr
          th Waiting
          th Scheduled
          th Pending
          th Dead
          th Paused
          th
      tbody
        tr.js-mosquito-queue-row data-queue-name="#{queue.name}"
          td.js-mosquito-waiting-count = sizes["waiting"]
          td.js-mosquito-scheduled-count = sizes["scheduled"]
          td.js-mosquito-pending-count = sizes["pending"]
          td.js-mosquito-dead-count data-queue-name="#{queue.name}" = sizes["dead"]
          td.js-mosquito-paused = queue.paused? ? "yes" : "no"
          td.js-mosquito-delete-dead
            - if sizes["dead"] > 0
              form action="/admin/mosquito/dead_jobs" method="post"
                input type="hidden" name="queue[name]" value="#{queue.name}"
                button.btn.btn-sm.btn-danger type="submit" Delete dead jobs

  - state = "waiting"
  - job_runs = queue.waiting_job_runs
  == render "src/views/admin/mosquito/_job_runs.slang"

  - state = "scheduled"
  - job_runs = queue.scheduled_job_runs
  == render "src/views/admin/mosquito/_job_runs.slang"

  - state = "pending"
  - job_runs = queue.pending_job_runs
  == render "src/views/admin/mosquito/_job_runs.slang"

  - state = "dead"
  - job_runs = queue.dead_job_runs
  == render "src/views/admin/mosquito/_job_runs.slang"
