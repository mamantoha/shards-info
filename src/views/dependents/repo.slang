.shards__shard.row
  .col-12
    .shards__shard_info
      h3.shards__shard_name
        a href="/repos/#{item_repo.owner.login}/#{item_repo.name}" = item_repo.name
      p.shards__shard_desc
        == Emoji.emojize(Autolink.auto_link(item_repo.description.to_s))
    .shards__shard_owner
      .shards__shard_owner_avatar
        img src="#{item_repo.owner.avatar_url}" alt="#{item_repo.owner.login}"
      .shards__shard_owner_name
        a href="/repos/#{item_repo.owner.login}" = item_repo.owner.login
