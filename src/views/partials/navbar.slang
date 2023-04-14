nav.navbar.navbar-expand-md.navbar-dark.fixed-top.bg-dark
  .container
    a.navbar-brand href="/"
      img.d-inline-block.align-top src="/images/logo_ua.svg" width="30" height="30" alt=""
      ' shards.info
    button.navbar-toggler type="button" data-bs-toggle="collapse" data-bs-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation"
      span.navbar-toggler-icon
    .collapse.navbar-collapse#navbarNavDropdown
      .navbar-nav.me-auto.mb-2.mb-lg-0
        ul.navbar-nav.me-auto
          li.nav-item
            a.nav-link href="/repositories"
              i.fas.fa-compass
              | Browse
           li.nav-item
            a.nav-link href="/stats"
              i.fas.fa-chart-simple
              | Stats
          li.nav-item
            a.nav-link href="#" data-bs-toggle="modal" data-bs-target="#aboutModal"
              i.fas.fa-circle-info
              | About
          li.nav-item
            div.form-check.form-switch.m-2
              input.form-check-input#switchTheme type="checkbox"

      .search-wrap
        div.form-group.has-search
          span.fa.fa-search.form-control-feedback
          form.d-flex.navbar-form.navbar-left#search action="/search" method="GET" autocomplete="off"
            input.form-control.me-2 aria-label="Search" name="query" type="search" placeholder="Search shards..." onClick="this.select();" value="#{Config.config.query}"

      ul.navbar-nav.me
        - if (current_user = current_user(env))
          li.nav-item.dropdown
            a.nav-link.dropdown-toggle#navbarDropdown href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false"
              img.rounded-circle src="#{current_user.image}" alt="#{current_user.nickname}" width="20" height="20"
            ul.dropdown-menu aria-labelledby="navbarDropdown"
              li
                .ms-2.p-2.fw-lighter.lh-1
                  i.fas.fa-user
                  strong= current_user.nickname
              li
                hr.dropdown-divider
              - if current_user.admin?
                li
                  a.dropdown-item href="/admin"
                    i.fas.fa-toolbox
                    | Admin
              li
                a.dropdown-item href="/logout"
                  i.fas.fa-right-from-bracket
                  | Sing out
        - else
          li.nav-item
            a.nav-link href="/auth/github"
              i.fas.fa-sign-in-alt
