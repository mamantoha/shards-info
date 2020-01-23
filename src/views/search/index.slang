div
  h1.page__heading
    ' search
    i.page__subheading
      ' for
      span class="badge badge-info"
        = query
    .result_stats
      = total_count
      ' results

== render "src/views/repositories/_list.slang"
== paginator
