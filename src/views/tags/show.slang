div
  h1.page__heading
    ' tagged
    i.page__subheading
      ' with
      = tag.name
    .result_stats
      = total_count
      ' results

== render "src/views/repositories/_list.slang"
== paginator
