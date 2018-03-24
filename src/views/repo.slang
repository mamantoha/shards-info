nav aria-label="breadcrumb"
  ol class="breadcrumb bg-light"
    li class="breadcrumb-item"
      a href="/" Home
    li class="breadcrumb-item"
      a href="/repos/#{repo.owner.login}" = repo.owner.login
    li class="breadcrumb-item active" aria-current="page" = repo.name
.row
  .col-8.shard__main
    h1.page__heading
      = repo.name
      i.page__subheading
        = repo.latest_release
    .shard__intro
      = Emoji.emojize(repo.description.to_s)
    .row
      .col-6
        .shard__releases
          h3.list__heading Releases:
          ul.list__items
            - repo.releases.first(5).each do |release|
              li.shard__release-wrap
                = release.tag_name
                small
                  ' -
                  = release.published_at.to_s("%B %-d, %Y")
      .col-6
        .shard__dependent_shards
          h3.list__heading = "Dependent shards(#{dependent_repos.total_count}):"
          ul.list__items
            - dependent_repos.items.each do |item|
              li
                i class="fab fa-github"
                a href="/repos/#{item.repository.full_name}" = item.repository.name
    .shard__owner
      h3.list__heading Owner:
      .shards__shard_owner
        .shards__shard_owner_avatar
          img src="#{repo.owner.avatar_url}"
        .shards__shard_owner_name
          a href="/repos/#{repo.owner.login}" = repo.owner.login
  .col-4
    .list__heading Github statistic:
    ul.shard__statistic
      li
        i class="fas fa-star" title="Stars"
        = repo.watchers_count
      li
        i class="fas fa-code-branch" title="Forks"
        = repo.forks_count
      li
        i class="fas fa-eye" title="Watchers"
        = repo.subscribers_count
      li
        i class="fas fa-exclamation-circle" title="Open issues"
        = repo.open_issues_count
    h3.list__heading License:
    p
      = repo.license_name
    h3.list__heading Links:
    ul.shard__links
      li
        a href="#{repo.html_url}" target="_blank" Homepage
