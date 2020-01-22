div
  h1.page__heading
    ' search
    i class="page__subheading"
      ' for
      em = query
    .result_stats
      = total_count
      ' results

== render "src/views/repositories/_list.slang"
== paginator
