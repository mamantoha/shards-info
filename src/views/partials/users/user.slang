.shards__shard.d-flex
  a.d-block.mr-2.mt-1 href="/repos/#{user.login}"
    img.avatar src="#{user.avatar_url}" alt="#{user.login}" width="32" height="32"

  .width-full
    .shards__shard_info
      h3.shards__shard_name.css-truncate
        a href="/repos/#{user.login}"
            == "#{user.login}"
