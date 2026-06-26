.container
  div.mt-3
    nav aria-label="breadcrumb"
      ol.breadcrumb
        li.breadcrumb-item
          a href="/admin" Admin
        li.breadcrumb-item.active aria-current="page" Mosquito

  h2 Mosquito

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
            th Paused
        tbody
          - queues.each do |queue|
            - sizes = queue.size_details
            tr
              td = queue.name
              td = sizes["waiting"]
              td = sizes["scheduled"]
              td = sizes["pending"]
              td = sizes["dead"]
              td = queue.paused? ? "yes" : "no"

    - queues.each do |queue|
      h3.mt-4 = queue.name

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
