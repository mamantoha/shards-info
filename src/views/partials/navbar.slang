nav.navbar.fixed-top
  .container-fluid
    button.btn data-bs-toggle="modal" data-bs-target="#sidebar-modal"
      span.navbar-toggler-icon
    a.navbar-brand.mx-auto href="/"
      img.d-inline-block.align-top src="/images/logo_ua.svg" width="30" height="30" alt=""
      ' shards.info
    ul.navbar-nav.me
      - if current_admin?(env)
        - admin_nickname = env.session.string?("admin_nickname") || ""
        - admin_image = env.session.string?("admin_image") || ""
        a.nav-link.dropdown-toggle#navbarDropdown href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false"
          img.rounded-circle src="#{admin_image}" alt="#{admin_nickname}" width="20" height="20"
        ul.dropdown-menu.dropdown-menu-end.position-absolute aria-labelledby="navbarDropdown"
          li
            .ms-2.p-2.fw-lighter.lh-1
              i.fas.fa-user
              strong= admin_nickname
          li
            hr.dropdown-divider
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
