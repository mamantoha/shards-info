div
  h1.page__heading
    .container
      ' search
      span.page__subheading
        ' for
        span class="badge badge-info"
          = query
      .result_stats
        = total_count
        ' results
.container
  == render "src/views/repositories/_list.slang"
== paginator
