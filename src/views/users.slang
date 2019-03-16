div
  h1.page__heading
    ' Crystal developers
    .result_stats
      = users.total_count
      ' users
- if users.total_count != 0
  - users_array = users.items
  == render "src/views/partials/users/users.slang"
  == paginator
