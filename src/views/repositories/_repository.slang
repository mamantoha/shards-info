/.shards__shard.d-flex class="#{repo.fork ? "forked" : ""}"
.shards__shard.d-flex
  - if additional_info
    a.d-block.mr-2.mt-1 href="/#{repo.provider}/#{repo.user.login}"
      img.avatar src="#{repo.user.decorate.avatar}" alt="#{repo.user.login}"

  .width-full
    .shards__shard_info
      /- if repo.fork == true
        p.shards__shard_fork
          | Forked repository
      h3.shards__shard_name.css-truncate
        a href="/#{repo.provider}/#{repo.user.login}/#{repo.name}"
          - if additional_info
            == "#{repo.user.login}/<span class='text-normal'>#{repo.name}</span>"
          - else
            == repo.name

      p.shards__shard_desc.dont-break-out
        == Emoji.emojize(Autolink.auto_link(repo.description.to_s))
    .shard__topics
      / TODO: for some reason repo.tags breaks html template
      / - repo.tags.each do |tag|
      - repo.tag_names.each do |tag|
        a href="/tags/#{tag}" class="badge badge-secondary" = tag
    .shards__shard_github
      ul
        li
          i class="fas fa-star" title="Stars"
          = repo.stars_count
        li
          i class="fas fa-code-branch" title="Forks"
          = repo.forks_count
        li
          i class="fas fa-exclamation-circle" title="Open issues"
          = repo.open_issues_count
        li
          .shards__shard_updated
            = "Updated #{HumanizeTime.distance_of_time_in_words(repo.last_activity_at, Time.local)} ago"
