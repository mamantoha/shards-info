.shards__shard.d-flex
  a.d-block.mr-2.mt-1 href="/repos/#{repo.owner.login}"
    img.avatar src="#{repo.owner.avatar_url}" alt="#{repo.owner.login}"

  .width-full
    .shards__shard_info
      h3.shards__shard_name.css-truncate
        a href="/repos/#{repo.owner.login}/#{repo.name}"
          - if additional_info
            == "#{repo.owner.login}/<span class='text-normal'>#{repo.name}</span>"
          - else
            == repo.name

      p.shards__shard_desc.dont-break-out
        == Emoji.emojize(Autolink.auto_link(repo.description.to_s))
    .shard__topics
      - if topics = repo.topics
        - topics.each do |topic|
          a href="/repos?query=topic:#{topic}" class="badge badge-secondary" = topic
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
        li
          .shards__shard_updated
            = "Updated #{HumanizeTime.distance_of_time_in_words(repo.updated_at, Time.local)} ago"
