- repos_array.each do |repo|
  .shards__shard.row
    .col-12
      .shards__shard_info
        h3.shards__shard_name
          a href="/repos/#{repo.owner.login}/#{repo.name}" = repo.name
        p.shards__shard_desc
          == Emoji.emojize(Autolink.auto_link(repo.description.to_s, html: {"target" => "_blank"}))
      .shards__shard_owner
        .shards__shard_owner_avatar
          img src="#{repo.owner.avatar_url}" alt="#{repo.owner.login}"
        .shards__shard_owner_name
          a href="/repos/#{repo.owner.login}" = repo.owner.login
      .shards__shard_updated
        = "Updated #{HumanizeTime.distance_of_time_in_words(repo.pushed_at, Time.now)} ago"
      .shards__shard_github
        ul
          li
            i class="fas fa-star" title="Stars"
            = repo.watchers_count
          li
            i class="fas fa-code-branch" title="Forks"
            = repo.forks_count
          li
            i class="fas fa-exclamation-circle" title="Open issues"
            = repo.open_issues_count
