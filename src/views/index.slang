ul class="nav nav-tabs" id="reposTab" role="tablist"
  li class="nav-item"
    a class="nav-link active" id="popular-tab" href="#popular" role="tab" data-toggle="tab" aria-controls="popular" aria-selected="true"
      i class="fas fa-fire"
      ' Most popular
  li class="nav-item"
    a class="nav-link" id="recently-tab" href="#recently" role="tab" data-toggle="tab" aria-controls="recently" aria-selected="false"
      i class="fas fa-clock"
      ' Recently updated

div class="tab-content"
  div role="tabpanel" class="tab-pane fade show active" id="popular" aria-labelledby="popular-tab"
    - popular_repos.items.each do |repo|
      .shards__shard.row
        .col-8
          .shards__shard_info
            h3.shards__shard_name
              = repo.name
            p.shards__shard_desc
              = Emoji.emojize(repo.description.to_s)
          .shards__shard_owner
            .shards__shard_owner_avatar
              img src="#{repo.owner.avatar_url}"
            .shards__shard_owner_name
              = repo.owner.login
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
  div role="tabpanel" class="tab-pane fade" id="recently" aria-labelledby="recently-tab"
    - recently_repos.items.each do |repo|
      .shards__shard.row
        .col-8
          .shards__shard_info
            h3.shards__shard_name
              = repo.name
            p.shards__shard_desc
              = Emoji.emojize(repo.description.to_s)
          .shards__shard_owner
            .shards__shard_owner_avatar
              img src="#{repo.owner.avatar_url}"
            .shards__shard_owner_name
              = repo.owner.login
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
