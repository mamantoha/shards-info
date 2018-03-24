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
  .col-4
