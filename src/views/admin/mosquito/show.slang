.container
  div.mt-3
    nav aria-label="breadcrumb"
      ol.breadcrumb
        li.breadcrumb-item
          a href="/admin" Admin
        li.breadcrumb-item
          a href="/admin/mosquito" Mosquito
        li.breadcrumb-item.active aria-current="page" = queue.name

  h2 = queue.name

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
        tr
          td = sizes["waiting"]
          td = sizes["scheduled"]
          td = sizes["pending"]
          td.js-mosquito-dead-count data-queue-name="#{queue.name}" = sizes["dead"]
          td = queue.paused? ? "yes" : "no"
          td
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
