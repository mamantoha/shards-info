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
    .js-mosquito-workers
      - overseers.each do |overseer|
        - executors = overseer.executors
        .mb-4.js-mosquito-worker-group data-overseer-id="#{overseer.instance_id}"
          h3.h5 = overseer.instance_id
          dl.row
            dt.col-sm-3 Last heartbeat
            dd.col-sm-9 = overseer.last_heartbeat.try(&.by_example("January 2, 2006 @ 15:04")) || ""
            dt.col-sm-3 Executors
            dd.col-sm-9 = executors.size

          - if executors.empty?
            p.text-muted No executors.
          - else
            .table-responsive
              table.table.table-striped
                thead
                  tr
                    th Executor
                    th Heartbeat
                    th Current job
                    th Current queue
                tbody
                  - executors.each do |executor|
                    tr.js-mosquito-worker-row data-overseer-id="#{overseer.instance_id}" data-executor-id="#{executor.instance_id}"
                      td = executor.instance_id
                      td = executor.heartbeat.try(&.by_example("January 2, 2006 @ 15:04"))
                      td = executor.current_job || "Idle"
                      td = executor.current_job_queue || ""
