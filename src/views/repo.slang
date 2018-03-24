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
    .shard__intro
      = repo.description
    .shard__releases
      h3.list__heading Releases:
      ul.list__items
        - repo.releases.first(5).each do |release|
          li.shard__release-wrap
            = release.tag_name
            small
              ' -
              = release.published_at.to_s("%B %-d, %Y")
    .shard__owner
      h3.list__heading Owner:
      = repo.owner.login
  .col-4
