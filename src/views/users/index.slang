== render "src/views/partials/subnav.slang"
div
  h1.page__heading
    .container
      ' Crystal community
      .result_stats
        = total_count
        ' developers
.container
  .users
    - users.each(fetch_columns: true) do |user|
      == render "src/views/users/_user_card.slang"

  == paginator
