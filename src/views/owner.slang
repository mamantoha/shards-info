- repos_array = repos
.row
  .col-md-3
    == render "src/views/partials/user.slang"
  .col-md-9
    == render "src/views/partials/user_repos.slang"
