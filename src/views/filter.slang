div
  h1.page__heading
    ' search
    i class="page__subheading"
      ' for
      em = query
- if repos.total_count != 0
  - repos_array = repos.items
  == paginator
  == render "src/views/partials/repos.slang"
  == paginator
