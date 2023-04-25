.d-flex.user
  .d-block.me-2.mt-1
    .avatar_block
      img.avatar src="#{user.decorate.avatar(64)}" alt="#{user.login}"
  .row.width-full
    .col-md-3.users__user
      i class="#{user.decorate.kind_icon}"
      a href="/#{user.provider}/#{user.login}/"
        = user.decorate.full_name
      div
        i class="fab #{user.decorate.provider_icon}"
        = user.login
      .small.mb-4
        | #{user.attributes["repositories_count"]} repositories
    .col-md-9
      - if (repository = user.repositories.with_counts.order_by(stars_count: :desc).first(fetch_columns: true))
        .small.text-uppercase.mb-2
          i.text-warning.fas.fa-fire
          ' Popular repository
        div.users__popular_repository
          i class="#{repository.decorate.provider_icon}"
          a href="/#{user.provider}/#{user.login}/#{repository.name}/"
            = repository.name
        .mb-2
          = repository.decorate.description_html
        .small
          ul.list-inline.not-list
            li.list-inline-item
              i class="fas fa-star" title="Stars"
              = repository.stars_count
            li.list-inline-item
              i class="fas fa-code-branch" title="Forks"
              = repository.forks_count
            li.list-inline-item
              i class="fas fa-exclamation-circle" title="Open issues"
              = repository.open_issues_count
            li.list-inline-item
              i.fas.fa-box title="Used by"
              = repository.attributes["dependents_count"]
            li.list-inline-item
              i.fas.fa-sitemap title="Dependencies"
              = repository.attributes["dependencies_count"]
            li.list-inline-item
              i class="fas fa-rotate" title="Last activity"
              = repository.decorate.last_activity_ago
