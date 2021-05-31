.container
    div.mt-3
      nav aria-label="breadcrumb"
        ol.breadcrumb
          li.breadcrumb-item
            a href="/admin" Admin
          li.breadcrumb-item.active aria-current="page" Site admins

    table.table.table-striped
      thead
        tr
          th
          th Nickname
          th Name
          th Role
          th Url
      tbody
        - admins.each do |admin|
          tr
            td
              i class="#{admin.decorate.provider_icon}"
            td
              = admin.nickname
            td
              = admin.name
            td
              = admin.decorate.role_name
            td
              a href="#{admin.decorate.provider_url}" = admin.decorate.provider_url
  == paginator
