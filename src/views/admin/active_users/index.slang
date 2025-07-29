.container
    div.mt-3
      nav aria-label="breadcrumb"
        ol.breadcrumb
          li.breadcrumb-item
            a href="/admin" Admin
          li.breadcrumb-item.active aria-current="page" Active users

    h2
      = "Active users: #{keys.size}"
    table.table.table-striped
      thead
        tr
          th Key
          th Remote address
          th Location
          th User agent
      tbody
        - keys.each do |key|
          - if value = ACTIVE_USERS_CACHE.read(key)
            - user = JSON.parse(value)

            tr
              td
                = key
              th
                = user.try(&.["remote_address"]?)
              th
                - if location_value = user.try(&.["location"]).as_s?.try(&.presence)
                  - location = Ipapi::Location.from_json(location_value.to_json)
                  = "#{location.city}/#{location.country_name}"
              th
                = user.try(&.["user_agent"]?)
