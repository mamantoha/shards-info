.container
    div.mt-3
      nav aria-label="breadcrumb"
        ol.breadcrumb
          li.breadcrumb-item
            a href="/admin" Admin
          li.breadcrumb-item.active aria-current="page" Hidden users

    table.table.table-striped
      thead
        tr
          th
          th User
          th
      tbody
        - users.each(fetch_columns: true) do |user|
          tr
            td
              i class="#{user.decorate.provider_icon}"
            td
              a href="/#{user.provider}/#{user.login}/"
                = user.login
              | (#{user.name})
            td
              | #{user.attributes["repositories_count"]} repositories
  == paginator
