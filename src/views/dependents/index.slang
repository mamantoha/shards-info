div
  .page__heading
    .container
      .row
        .col
          h1.container
            | dependent
            i.page__subheading
              ' on
              a href="/#{repository.provider}/#{repository.decorate.full_name}/" #{repository.decorate.full_name}
            .result_stats
              | Displaying
              strong= "#{offset + 1}-#{[page * per_page, total_count].min}"
              | of
              strong= "#{total_count}"
              | total results
        .col.text-end
          .row.align-items-center
            .col-auto
              label
                | Sort by
            .col-auto
              .dropdown
                button.btn.btn-secondary.btn-sm.dropdown-toggle type="button" data-bs-toggle="dropdown" aria-expanded="false"
                  = Helpers::REPOSITORIES_SORT_OPTIONS[sort]
                ul.dropdown-menu
                  li
                    - Helpers::REPOSITORIES_SORT_OPTIONS.each do |key, value|
                      a.dropdown-item href="#{route_path}?sort=#{key}" class="#{key == sort ? "disabled" : ""}"
                        = value

.container
  == render "src/views/repositories/_list.slang"
== paginator
