.shards__shard.d-flex
  - if additional_info
    a.d-block.me-2.mt-1 href="/#{repository.provider}/#{repository.user.login}/"
      .avatar_block
        img.avatar src="#{repository.user.decorate.avatar(64)}" alt="#{repository.user.login}"
        span.badge
          span class="fa-stack"
            i class="fas fa-circle fa-stack-2x"
            i class="#{repository.provider_icon} fa-stack-1x fa-inverse"
  .width-full
    .shards__shard_info
      .small.text-secondary
        - if repository.fork
          | forked from
          - if (upstream_repository = repository.upstream_repository)
            a href="#{upstream_repository.parent.decorate.show_path}"
              = upstream_repository.parent.decorate.full_name
      h2.shards__shard_name.css-truncate
        a href="/#{repository.provider}/#{repository.decorate.full_name}/"
          - if additional_info
            == "#{repository.user.login}/<span class='text-normal'>#{repository.name}</span>"
          - else
            == repository.name
        - if repository.archived
          span.archived-badge.badge.bg-warning.text-light
            | Archived

      p.shards__shard_desc.dont-break-out
        == repository.decorate.description_html.to_s
    .shard__topics
      - repository.tags.each do |tag|
        a href="/tags/#{tag.name}" class="badge bg-secondary text-monospace" = tag.name
    .shards__shard_stats
      ul
        li
          i class="fas fa-star" title="Stars"
          = repository.stars_count
        li
          i class="fas fa-code-branch" title="Forks"
          = repository.attributes["forks_count"]
        li
          i class="fas fa-exclamation-circle" title="Open issues"
          = repository.open_issues_count
        li
          i.fas.fa-box title="Used by"
          = repository.attributes["dependents_count"]
        li
          i.fas.fa-sitemap title="Dependencies"
          = repository.attributes["dependencies_count"]
        li
          i class="fas fa-rotate" title="Last activity"
          = repository.decorate.last_activity_ago
