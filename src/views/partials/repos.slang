- repos.items.each do |repo|
  .shards__shard.row
    .col-8
      .shards__shard_info
        h3.shards__shard_name
          a href="#{repo.owner.login}/#{repo.name}" = repo.name
        p.shards__shard_desc
          = Emoji.emojize(repo.description.to_s)
      .shards__shard_owner
        .shards__shard_owner_avatar
          img src="#{repo.owner.avatar_url}"
        .shards__shard_owner_name
          a href="#{repo.owner.login}" = repo.owner.login
      .row
        .col-4
          = repo.license_name
        .col-8
          = "Updated #{HumanizeTime.distance_of_time_in_words(repo.pushed_at, Time.now)} ago"
    .col-2
      i class="fas fa-star"
      = repo.watchers_count
    .col-2
      a href="#{repo.html_url}" target="_blank"
        i class="fab fa-github"
