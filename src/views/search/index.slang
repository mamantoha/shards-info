div
  h1.page__heading
    .container
      ' search
      span.page__subheading
        ' for
        span class="badge badge-info"
          = query
      .result_stats
        = total_count
        ' results
.container
  - if total_count > 0
    == render "src/views/partials/sort_repositories_dropdown.slang"
  == render "src/views/repositories/_list.slang"
== paginator
