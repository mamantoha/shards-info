.container
  div.mt-3
    nav aria-label="breadcrumb"
      ol.breadcrumb
        li.breadcrumb-item
          a href="/admin" Admin
        li.breadcrumb-item
          a href="/admin/visitors" Visitors
        li.breadcrumb-item.active aria-current="page" = visitor.id

  h2 Visitor

  dl.row
    dt.col-sm-3 ID
    dd.col-sm-9.text-break = visitor.id

    dt.col-sm-3 Address
    dd.col-sm-9 = visitor.remote_address

    dt.col-sm-3 Location
    dd.col-sm-9
      - location_value = visitor.location.as_h?
      - if location_value && !location_value.empty?
        - location = Ipapi::Location.from_json(visitor.location.to_json)
        = "#{FlagEmoji.from_country_code(location.country_code)} #{location.city}/#{location.country_name}"

    dt.col-sm-3 User agent
    dd.col-sm-9.text-break = visitor.user_agent

    dt.col-sm-3 First seen
    dd.col-sm-9
      time.js-local-datetime datetime=visitor.created_at.to_rfc3339 = visitor.created_at.to_s("%Y-%m-%d %H:%M:%S")

    dt.col-sm-3 Last seen
    dd.col-sm-9
      time.js-local-datetime datetime=visitor.updated_at.to_rfc3339 = visitor.updated_at.to_s("%Y-%m-%d %H:%M:%S")

  h3 = "Events: #{visitor.events_count}"

  .table-responsive
    table.table.table-striped
      thead
        tr
          th Time
          th Method
          th Path
          th Parameters
      tbody
        - events.each do |event|
          tr
            td.text-nowrap
              time.js-local-datetime datetime=event.created_at.to_rfc3339 = event.created_at.to_s("%Y-%m-%d %H:%M:%S")
            td = event.method
            td.text-break = event.path
            td.text-break
              - params = event.params.as_h?
              - if params && !params.empty?
                code = event.params.to_json

  == paginator
