nav.navbar.navbar-expand-md.navbar-dark.fixed-top.bg-dark
  .container
    a.navbar-brand href="/"
      img src="/images/logo.svg" width="30" height="30" class="d-inline-block align-top" alt=""
      ' shards.info
    button.navbar-toggler type="button" data-bs-toggle="collapse" data-bs-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation"
      span.navbar-toggler-icon
    .collapse.navbar-collapse#navbarNavDropdown
      .navbar-nav.me-auto.mb-2.mb-lg-0
        ul.navbar-nav.me-auto
          li.nav-item
            a.nav-link href="#" data-bs-toggle="modal" data-bs-target="#aboutModal"
              | About
      == render "src/views/partials/search_input.slang"
