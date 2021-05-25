div
  h1.page__heading
    .container
      ' Hidden repositories
.container
  == render "src/views/repositories/_list.slang"
  == paginator
