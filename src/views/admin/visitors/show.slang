.container
  div.mt-3
    nav aria-label="breadcrumb"
      ol.breadcrumb
        li.breadcrumb-item
          a href="/admin" Admin
        li.breadcrumb-item
          a href="/admin/visitors" Visitors
        li.breadcrumb-item.active aria-current="page" = visitor.id

  .d-flex.justify-content-between.align-items-center.gap-3
    h2 Visitor
    form action="/admin/visitors/#{visitor.id}/delete" method="post" onsubmit="return confirm('Delete this visitor and all events?')"
      button.btn.btn-danger type="submit"
        i.fa-solid.fa-trash.me-2
        | Delete visitor

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
      == ViewHelpers.local_datetime(visitor.created_at)

    dt.col-sm-3 Last seen
    dd.col-sm-9
      == ViewHelpers.local_datetime(visitor.updated_at)

  h3 = "Events: #{visitor.events_count}"

  .table-responsive.stacked-table-responsive
    table.table.table-striped.stacked-table
      thead
        tr
          th Time
          th Method
          th Duration
          th Route
          th Path
          th Parameters
          th Referrer
      tbody
        - events.each do |event|
          tr
            td.text-nowrap data-label="Time"
              == ViewHelpers.local_datetime(event.created_at)
            td data-label="Method" = event.method
            td.text-nowrap data-label="Duration" = "#{event.duration_ms} ms"
            td.text-break data-label="Route" = event.route
            td.text-break data-label="Path" = event.path
            td.text-break data-label="Parameters"
              - params = event.params.as_h?
              - if params && !params.empty?
                code = event.params.to_json
            td.text-break data-label="Referrer" = event.referrer

  == paginator
