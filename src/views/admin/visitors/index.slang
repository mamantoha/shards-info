.container
    div.mt-3
      nav aria-label="breadcrumb"
        ol.breadcrumb
          li.breadcrumb-item
            a href="/admin" Admin
          li.breadcrumb-item.active aria-current="page" Visitors

    h2
      = "Visitors: #{total_count}"
    .table-responsive.stacked-table-responsive
      table.table.table-striped.stacked-table
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
              td data-label="Visitor ID"
                a href="/admin/visitors/#{visitor.id}"
                  = visitor.id
              td data-label="Address"
                = visitor.remote_address
              td data-label="Location"
                - location_value = visitor.location.as_h?
                - if location_value && !location_value.empty?
                  - location = Ipapi::Location.from_json(visitor.location.to_json)
                  = "#{FlagEmoji.from_country_code(location.country_code)} #{location.city}/#{location.country_name}"
              td data-label="User agent"
                = visitor.user_agent
              td data-label="Events"
                = visitor.events_count
              td data-label="First seen"
                == ViewHelpers.local_datetime(visitor.created_at)
              td data-label="Last seen"
                == ViewHelpers.local_datetime(visitor.updated_at)
== paginator
