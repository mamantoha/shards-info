div
  h1.page__heading
    ' dependent
    i.page__subheading
      ' on
      a href="/github/#{repo.full_name}" #{repo.full_name}
    .result_stats
      = dependent_repos.total_count
      ' repositories

- dependent_repos.items.each do |item|
  - repo = item.repository
  == render "src/views/dependents/repo_item.slang"
== paginator
