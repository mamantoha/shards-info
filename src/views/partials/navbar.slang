nav.navbar.fixed-top
  .container-fluid
    button.btn data-bs-toggle="modal" data-bs-target="#sidebar-modal"
      span.navbar-toggler-icon
    a.navbar-brand.mx-auto href="/"
      img.d-inline-block.align-top src="/images/logo_ua.svg" width="30" height="30" alt=""
      ' shards.info
    ul.navbar-nav.me
      - if (current_user = current_user(env))
        a.nav-link.dropdown-toggle#navbarDropdown href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false"
          img.rounded-circle src="#{current_user.image}" alt="#{current_user.nickname}" width="20" height="20"
        ul.dropdown-menu.dropdown-menu-end.position-absolute aria-labelledby="navbarDropdown"
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
              | Sign out
      - else
        li.nav-item
          a.nav-link href="/auth/github"
            i.fas.fa-sign-in-alt
