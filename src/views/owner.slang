nav aria-label="breadcrumb"
nav aria-label="breadcrumb"
  ol class="breadcrumb bg-light"
    li class="breadcrumb-item"
      a href="/" Home
    li class="breadcrumb-item active" aria-current="page"
      = owner

- repos_array = repos
== render "src/views/partials/repos.slang"
