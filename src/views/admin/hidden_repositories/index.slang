.container
    div.mt-3
      nav aria-label="breadcrumb"
        ol.breadcrumb
          li.breadcrumb-item
            a href="/admin" Admin
          li.breadcrumb-item.active aria-current="page" Hidden repositories

    table.table.table-striped
      thead
        tr
          th
          th Repository
          th User
          th Last activity
      tbody
        - repositories.each(fetch_columns: true) do |repository|
          tr
            td
              i class="#{repository.decorate.provider_icon}"
            td
              a href="/#{repository.provider}/#{repository.decorate.full_name}/" = repository.name
            td
              a href="/#{repository.provider}/#{repository.user.login}/" = repository.user.login
            td
              = repository.last_activity_at.by_example("January 2, 2006 @ 15:04")
  == paginator
