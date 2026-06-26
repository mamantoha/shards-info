.container.js-mosquito-content
  div.mt-3
    nav aria-label="breadcrumb"
      ol.breadcrumb
        li.breadcrumb-item
          a href="/admin" Admin
        li.breadcrumb-item
          a href="/admin/mosquito" Mosquito
        li.breadcrumb-item.active aria-current="page" Workers

  .d-flex.align-items-center.justify-content-between
    h2 Workers
    button.btn.btn-sm.btn-outline-secondary.js-live-poll type="button" data-interval="5000" data-url="/admin/mosquito/workers.json" Live Poll

  - if overseers.empty?
    p No workers found.
  - else
    .table-responsive
      table.table.table-striped
        thead
          tr
            th Overseer
            th Overseer heartbeat
            th Executor
            th Executor heartbeat
            th Current job
            th Current queue
        tbody.js-mosquito-workers
          - overseers.each do |overseer|
            - executors = overseer.executors
            - if executors.empty?
              tr.js-mosquito-worker-row data-overseer-id="#{overseer.instance_id}" data-executor-id=""
                td = overseer.instance_id
                td = overseer.last_heartbeat.try(&.by_example("January 2, 2006 @ 15:04"))
                td.text-muted colspan="4" No executors.
            - else
              - executors.each do |executor|
                tr.js-mosquito-worker-row data-overseer-id="#{overseer.instance_id}" data-executor-id="#{executor.instance_id}"
                  td = overseer.instance_id
                  td = overseer.last_heartbeat.try(&.by_example("January 2, 2006 @ 15:04"))
                  td = executor.instance_id
                  td = executor.heartbeat.try(&.by_example("January 2, 2006 @ 15:04"))
                  td = executor.current_job || ""
                  td = executor.current_job_queue || ""
