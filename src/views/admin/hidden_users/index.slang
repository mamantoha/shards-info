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
      tbody
        - users.each do |user|
          tr
            td
              i class="#{user.decorate.provider_icon}"
            td
              a href="/#{user.provider}/#{user.login}/" = user.login
  == paginator
