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
  - if total_count > 0
    .row.justify-content-end
      .col-auto.vertical-center
        label
          | Sort by
      .col-auto
        .dropdown
          button.btn.btn-secondary.btn-sm.dropdown-toggle type="button" data-bs-toggle="dropdown" aria-expanded="false"
            = Helpers::REPOSITORIES_SORT_OPTIONS[sort]
          ul.dropdown-menu
            li
              - Helpers::REPOSITORIES_SORT_OPTIONS.each do |key, value|
                a.dropdown-item href="/search?query=#{query_param}&page=#{page}&sort=#{key}" class="#{key == sort ? "disabled" : ""}"
                  = value
  == render "src/views/repositories/_list.slang"
== paginator
