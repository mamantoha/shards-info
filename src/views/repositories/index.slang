div
  .page__heading
    .container
      .row
        .col
          h1.container
            | All Shards
            .result_stats
              | Displaying
              strong= "#{offset + 1}-#{[page * per_page, total_count].min}"
              | of
              strong= "#{total_count}"
              | total results

.container
  == render "src/views/partials/sort_repositories_dropdown.slang"
  == render "src/views/repositories/_list.slang"
== paginator
