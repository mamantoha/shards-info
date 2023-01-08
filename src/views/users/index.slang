== render "src/views/partials/subnav.slang"
div
  h1.page__heading
    .container
      ' Crystal community
      .result_stats
        | Displaying
        strong= "#{offset + 1}-#{[page * per_page, total_count].min}"
        | of
        strong= "#{total_count}"
        | total results
.container
  .users
    - users.each(fetch_columns: true) do |user|
      == render "src/views/users/_user_item.slang"
== paginator
