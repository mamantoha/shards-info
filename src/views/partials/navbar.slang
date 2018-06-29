nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top"
  .container
    a class="navbar-brand" href="/"
      img src="/images/logo.svg" width="30" height="30" class="d-inline-block align-top" alt=""
      ' Crystal Shards
    button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation"
      span class="navbar-toggler-icon"
    div class="collapse navbar-collapse" id="navbarSupportedContent"
      ul class="navbar-nav mr-auto"
      == render "src/views/partials/search_input.slang"
