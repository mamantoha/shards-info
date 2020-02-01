nav.navbar.navbar-expand-md.navbar-dark.fixed-top.bg-dark
  .container
    a.navbar-brand href="/"
      img src="/images/logo.svg" width="30" height="30" class="d-inline-block align-top" alt=""
      ' shards.info
    button.navbar-toggler aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation" data-target="#navbarCollapse" data-toggle="collapse" type="button"
      span.navbar-toggler-icon
    #navbarCollapse.collapse.navbar-collapse
      ul.navbar-nav.mr-auto
        li.nav-item
          a.nav-link href="/users"
            | Users
        li.nav-item
          a.nav-link href="#aboutModal" data-toggle="modal" data-target="#aboutModal"
            | About
      == render "src/views/partials/search_input.slang"
