.d-flex.user
  .d-block.mr-2.mt-1
    img.avatar src="#{user.avatar_url}" alt="#{user.login}"
  .row.width-full
    .col-md-2
      a href="/#{user.provider}/#{user.login}"
        = "#{user.decorate.full_name}"
      .text-muted
        i class="fab #{user.decorate.provider_icon}"
        = "#{user.login}"
      .small.mb-4
        | #{user.attributes["repositories_count"]} repositories
    .col-md-10
      - if repository = user.repositories.order_by({stars_count: :desc}).first
        .small.text-muted.text-uppercase.mb-2
          i.text-warning.fas.fa-fire
          ' Popular repository
        div
          i class="#{repository.decorate.provider_icon}"
          a href="/#{user.provider}/#{user.login}/#{repository.name}"
            = repository.name
        .text-muted.mb-2
          = repository.description
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
              i class="fas fa-clock" title="Last activity"
              = repository.decorate.last_activity_ago
