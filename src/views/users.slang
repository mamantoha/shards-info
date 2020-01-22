div
  h1.page__heading
    ' Crystal developers
    .result_stats
      = total_count
      ' users

.d-flex.align-content-start.justify-content-center.flex-wrap
  - users.each(fetch_columns: true) do |user|
    == render "src/views/users/user.slang"

== paginator
