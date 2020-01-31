.shards__shard.d-flex
  - if additional_info
    a.d-block.mr-2.mt-1 href="/#{repository.provider}/#{repository.user.login}"
      .avatar_block
        img.avatar src="#{repository.user.decorate.avatar}" alt="#{repository.user.login}"
        span.badge
          span class="fa-stack"
            i class="fas fa-circle fa-stack-2x"
            i class="fab fa-#{repository.provider} fa-stack-1x fa-inverse"
  .width-full
    .shards__shard_info
      h3.shards__shard_name.css-truncate
        a href="/#{repository.provider}/#{repository.user.login}/#{repository.name}"
          - if additional_info
            == "#{repository.user.login}/<span class='text-normal'>#{repository.name}</span>"
          - else
            == repository.name

      p.shards__shard_desc.dont-break-out
        == Emoji.emojize(Autolink.auto_link(repository.description.to_s))
    .shard__topics
      / TODO: for some reason repository.tags breaks html template
      / - repository.tags.each do |tag|
      - repository.tag_names.each do |tag|
        a href="/tags/#{tag}" class="badge badge-secondary" = tag
    .shards__shard_github
      ul
        li
          i class="fas fa-star" title="Stars"
          = repository.stars_count
        li
          i class="fas fa-code-branch" title="Forks"
          = repository.forks_count
        li
          i class="fas fa-exclamation-circle" title="Open issues"
          = repository.open_issues_count
        li
          .shards__shard_updated
            = "Updated #{HumanizeTime.distance_of_time_in_words(repository.last_activity_at, Time.local)} ago"
