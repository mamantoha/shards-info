div
  h4.page__heading.text-right
    = repos.total_count
    ' shards found
- if repos.total_count != 0
  - repos_array = repos.items
  == render "src/views/partials/pagination.slang"
  == render "src/views/partials/repos.slang"
  == render "src/views/partials/pagination.slang"
