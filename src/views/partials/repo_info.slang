.row
   .col-md-6
     .shard__releases
       h3.list__heading Releases:
       ul.list__items.not-list
         - repo.releases.first(5).each do |release|
           li.shard__release-wrap
             = release.tag_name
             small
               ' -
               = release.published_at.to_s("%B %-d, %Y")
   .col-md-6
     .shard__dependencies
       h3.list__heading Dependencies:
       ul.list__items.not-list
         - dependencies.each do |key, value|
           li
             i class="fab fa-github"
             - if value["github"]?
               a href="/repos/#{value["github"]}" = key
             - else
               = key
.row
   .col-md-6
     .shard__dependent_shards
       h3.list__heading = "Dependent shards(#{dependent_repos.total_count}):"
       ul.list__items.not-list
         - dependent_repos.items.each do |item|
           li
             i class="fab fa-github"
             a href="/repos/#{item.repository.full_name}" = item.repository.name
  .col-md-6
     .shard__development_dependencies
       h3.list__heading Development dependencies:
       ul.list__items.not-list
         - development_dependencies.each do |key, value|
           li
             i class="fab fa-github"
             - if value["github"]?
               a href="/repos/#{value["github"]}" = key
             - else
               = key
.row
  .col-12
    .shard__owner
      h3.list__heading Owner:
      .shards__shard_owner
        .shards__shard_owner_avatar
          img src="#{repo.owner.avatar_url}"
        .shards__shard_owner_name
          a href="/repos/#{repo.owner.login}" = repo.owner.login
