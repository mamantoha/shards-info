div
  h1.page__heading
    ' search
    i class="page__subheading"
      ' for
      em = query
    .result_stats
      = total_count
      ' results

- repos_array = repos
== render "src/views/partials/repos.slang"
== paginator
