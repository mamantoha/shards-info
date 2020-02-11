div
  h1.page__heading
    .container
      ' tagged
      span.page__subheading
        ' with
        span class="badge badge-info"
          = tag.name
      .result_stats
        = total_count
        ' results
.container
  == render "src/views/repositories/_list.slang"
  == paginator
