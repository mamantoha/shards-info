div
  h1.page__heading
    ' dependent
    i.page__subheading
      ' on
      a href="/#{repository.provider}/#{repository.full_name}" #{repository.full_name}
    .result_stats
      = total_count
      ' results

== render "src/views/repositories/_list.slang"
== paginator
