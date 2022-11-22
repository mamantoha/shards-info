div
  h1.page__heading
    .container
      ' repositories
      span.page__subheading
        ' with
        span class="badge" style="background-color: #{language.color};"
          = language.name
      .result_stats
        | Displaying
        strong= "#{offset + 1}-#{[page * per_page, total_count].min}"
        | of
        strong= "#{total_count}"
        | total results
.container
  == render "src/views/repositories/_list.slang"
== paginator
