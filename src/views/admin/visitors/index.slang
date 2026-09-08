.container
    div.mt-3
      nav aria-label="breadcrumb"
        ol.breadcrumb
          li.breadcrumb-item
            a href="/admin" Admin
          li.breadcrumb-item.active aria-current="page" Visitors

    h2
      = "Visitors: #{total_count}"
    .table-responsive
      table.table.table-striped
        thead
          tr
            th Visitor ID
            th Address
            th Location
            th User agent
            th Events
            th First seen
            th Last seen
        tbody
          - visitors.each do |visitor|
            tr
              td
                a href="/admin/visitors/#{visitor.id}"
                  = visitor.id
              td
                = visitor.remote_address
              td
                - location_value = visitor.location.as_h?
                - if location_value && !location_value.empty?
                  - location = Ipapi::Location.from_json(visitor.location.to_json)
                  = "#{FlagEmoji.from_country_code(location.country_code)} #{location.city}/#{location.country_name}"
              td
                = visitor.user_agent
              td
                = visitor.events_count
              td
                = visitor.created_at.by_example("January 2, 2006 @ 15:04")
              td
                = visitor.updated_at.by_example("January 2, 2006 @ 15:04")
== paginator
