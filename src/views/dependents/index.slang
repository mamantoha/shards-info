div
  h1.page__heading
    .container
      ' dependent
      i.page__subheading
        ' on
        a href="/#{repository.provider}/#{repository.decorate.full_name}/" #{repository.decorate.full_name}
      .result_stats
        | Displaying
        strong= "#{offset + 1}-#{page * per_page}"
        | of
        strong= "#{total_count}"
        | total results
.container
  == render "src/views/repositories/_list.slang"
== paginator
