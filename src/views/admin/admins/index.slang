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
          th Name
          th Role
          th Created at
          th Updated at
      tbody
        - admins.each do |admin|
          tr
            td
              a href="#{admin.decorate.provider_url}"
                i class="#{admin.decorate.provider_icon}"
            td
              = admin.nickname
              = "(#{admin.name})"
            td
              = admin.decorate.role_name
            td
              = admin.created_at.by_example("January 2, 2006 @ 15:04")
            td
              = admin.updated_at.by_example("January 2, 2006 @ 15:04")
  == paginator
