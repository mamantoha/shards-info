.shards__shard.d-flex
  a.d-block.mr-2.mt-1 href="/github/#{repo.owner.login}"
    img.avatar src="#{repo.owner.avatar_url}" alt="#{repo.owner.login}"

  .width-full
    .shards__shard_info
      h3.shards__shard_name.css-truncate
        a href="/github/#{repo.owner.login}/#{repo.name}"
          == "#{repo.owner.login}/<span class='text-normal'>#{repo.name}</span>"
      p.shards__shard_desc.dont-break-out
        == Emoji.emojize(Autolink.auto_link(repo.description.to_s))
