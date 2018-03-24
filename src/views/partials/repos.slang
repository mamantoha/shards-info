- repos.items.each do |repo|
  .shards__shard.row
    .col-8
      .shards__shard_info
        h3.shards__shard_name
          a href="/repos/#{repo.owner.login}/#{repo.name}" = repo.name
          i.page__subheading
            = repo.latest_release
        p.shards__shard_desc
          = Emoji.emojize(repo.description.to_s)
      .shards__shard_owner
        .shards__shard_owner_avatar
          img src="#{repo.owner.avatar_url}"
        .shards__shard_owner_name
          a href="/repos/#{repo.owner.login}" = repo.owner.login
      .row
        .col-4
          = repo.license_name
        .col-8
          = "Updated #{HumanizeTime.distance_of_time_in_words(repo.pushed_at, Time.now)} ago"
    .col-2
      p
        i class="fas fa-star" title="Stars"
        = repo.watchers_count
      p
        i class="fas fa-code-branch" title="Forks"
        = repo.forks_count
      p
        i class="fas fa-exclamation-circle" title="Open issues"
        = repo.open_issues_count
    .col-2
      a href="#{repo.html_url}" target="_blank"
        i class="fab fa-github"
