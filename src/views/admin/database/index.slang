.container
  div.mt-3
    nav aria-label="breadcrumb"
      ol.breadcrumb
        li.breadcrumb-item
          a href="/admin" Admin
        li.breadcrumb-item.active aria-current="page" Database

  .d-flex.align-items-center.justify-content-between
    h2 Database
    button.btn.btn-sm.btn-outline-secondary.js-live-poll type="button" data-interval="5000" data-url="/admin/database.json" Live Poll

  h3.h5 Connections
  .table-responsive
    table.table.table-striped
      thead
        tr
          th State
          th Count
      tbody.js-database-counts
        - activity_counts.each do |state, count|
          tr
            td = state
            td = count

  h3.h5 Activity
  table.table.table-striped.admin-database-activity
    thead
      tr
        th PID
        th State
        th Query started
        th Query
    tbody.js-database-activity
      - if activity_rows.empty?
        tr
          td.text-muted colspan="4" No activity.
      - else
        - activity_rows.each do |row|
          tr
            td = row[0]
            td = row[1] || ""
            td = row[2].try(&.to_s("%Y-%m-%d %H:%M:%S %:z")) || ""
            td
              pre.mb-0 = row[3] || ""
