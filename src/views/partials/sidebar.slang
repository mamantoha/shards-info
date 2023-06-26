#sidebar-modal.modal.fade tabindex="-1"
  .modal-dialog
    .modal-content
      .modal-header
        button#themeSwitcher.nav-link.pe-2
        .search-wrap
          div.form-group.has-search
            span.fa.fa-search.form-control-feedback
            form.d-flex.navbar-form.navbar-left#search action="/search" method="GET" autocomplete="off"
              input.form-control.me-2 aria-label="Search" name="query" type="search" placeholder="Search shards..." onClick="this.select();" value="#{Config.config.query}"
        button type="button" class="btn-close" data-bs-dismiss="modal"
      .modal-body
        .navbar-nav.me-auto.mb-2.mb-lg-0
          ul.nav.flex-column
            li.nav-item
              a.nav-link href="/repositories"
                i.fas.fa-compass
                | Browse repositories
            li.nav-item
              a.nav-link href="/stats"
                i.fas.fa-chart-simple
                | Statistics
            li.nav-item
              hr
            li.nav-item
              p.fs-6.fw-lighter External links
            li.nav-item
              a.nav-link href="https://stats.uptimerobot.com/m770xt1j6Q" target="_blank"
                i.fas.fa-wave-square
                | Service Status
            li.nav-item
              a.nav-link href="https://github.com/mamantoha/shards-info" target="_blank"
                i.fa-brands.fa-github
                | GitHub repository
      .modal-footer
        | © #{Time.utc.year}
