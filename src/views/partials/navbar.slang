nav.navbar.navbar-expand-md.navbar-dark.fixed-top.bg-dark
  .container
    .navbar-brand
      img src="/images/logo.svg" width="30" height="30" class="d-inline-block align-top" alt=""
      ' Crystal Shards
    button.navbar-toggler aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation" data-target="#navbarCollapse" data-toggle="collapse" type="button"
      span.navbar-toggler-icon
    #navbarCollapse.collapse.navbar-collapse
      ul.navbar-nav.mr-auto
        li.nav-item
          a.nav-link href="/"
            | Home
            span.sr-only (current)
        li.nav-item
          a.nav-link href="#aboutModal" data-toggle="modal" data-target="#aboutModal"
            | About
      == render "src/views/partials/search_input.slang"
