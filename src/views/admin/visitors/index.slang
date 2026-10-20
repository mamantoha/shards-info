.container
    div.mt-3
      nav aria-label="breadcrumb"
        ol.breadcrumb
          li.breadcrumb-item
            a href="/admin" Admin
          li.breadcrumb-item.active aria-current="page" Visitors

    section.card.mb-4 aria-labelledby="visitor-map-heading"
      .card-body
        .d-flex.flex-wrap.justify-content-between.align-items-center.gap-2.mb-2
          h2.h4#visitor-map-heading Visitors by country
          .btn-group.js-visitor-map-ranges role="group" aria-label="Visitor map date range"
            button.btn.btn-outline-secondary type="button" data-days="7" aria-pressed="false" 7 days
            button.btn.btn-outline-secondary type="button" data-days="30" aria-pressed="false" 30 days
            button.btn.btn-secondary type="button" data-days="90" aria-pressed="true" 90 days
        p.small Unique tracked visitors with at least 2 total events, active during the selected period, using their latest known country.
        #visitor-map.visitor-map data-url="/admin/visitors/countries.json" role="region" aria-label="World map of visitors by country"
        .small.mt-2.js-visitor-map-status role="status" Loading visitor map…
        .d-flex.align-items-center.gap-2.small.mt-2
          span 0
          .visitor-map-legend
          span.js-visitor-map-maximum 0 visitors
        .small.mt-2
          | Boundaries: Natural Earth

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
                .js-visitor-location
                  - location_value = visitor.location.as_h?
                  - if location_value && !location_value.empty?
                    - location = Ipapi::Location.from_json(visitor.location.to_json)
                    = "#{FlagEmoji.from_country_code(location.country_code)} #{location.city}/#{location.country_name}"
                button.btn.btn-sm.btn-outline-secondary.js-update-visitor-location type="button" data-url="/admin/visitors/#{visitor.id}/location" Update location
                .small.text-danger.js-visitor-location-error role="status"
              td data-label="User agent"
                = visitor.user_agent
              td data-label="Events"
                = visitor.events_count
              td data-label="First seen"
                == ViewHelpers.local_datetime(visitor.created_at)
              td data-label="Last seen"
                == ViewHelpers.local_datetime(visitor.updated_at)
== paginator
