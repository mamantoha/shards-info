.container
    div.mt-3
      nav aria-label="breadcrumb"
        ol.breadcrumb
          li.breadcrumb-item
            a href="/admin" Admin
          li.breadcrumb-item.active aria-current="page" Hidden repositories

    table.table.table-striped.table-hover
      thead
        tr
          th
          th Repository
          th User
      tbody
        - repositories.each do |repository|
          tr
            td
              i class="#{repository.decorate.provider_icon}"
            td
              a href="/#{repository.provider}/#{repository.decorate.full_name}/" = repository.name
            td
              a href="/#{repository.provider}/#{repository.user.login}/" = repository.user.login
  == paginator
