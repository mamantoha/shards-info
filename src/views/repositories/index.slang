div
  .page__heading
    .container
      .row
        .col
          h1.container
            | All Shards
            .result_stats
              | Displaying
              strong= "#{offset + 1}-#{page * per_page}"
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
                  = sort_options[sort]
                ul.dropdown-menu
                  li
                    - sort_options.each do |key, value|
                      a.dropdown-item href="/repositories?sort=#{key}" class="#{key == sort ? "disabled" : ""}"
                        = value

.container
  == render "src/views/repositories/_list.slang"
== paginator
