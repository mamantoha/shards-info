div
  h1.page__heading
    ' forks
    i.page__subheading
      ' of
      a href="/repos/#{repo.full_name}" #{repo.full_name}
    .result_stats
      = repo.forks_count
      ' repositories

- additional_info = true
- repo_forks.each do |item|
  - repo = item
  == render "src/views/forks/repo_item.slang"
