div
  h1.page__heading
    .container
      ' dependent
      i.page__subheading
        ' on
        a href="/#{repository.provider}/#{repository.decorate.full_name}" #{repository.decorate.full_name}
      .result_stats
        = total_count
        ' results
.container
  == render "src/views/repositories/_list.slang"
  == paginator
