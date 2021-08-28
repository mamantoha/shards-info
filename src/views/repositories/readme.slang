== render "src/views/repositories/_header.slang"

.container
  .row
    .col-md-8.col-sm-12.shard__main
      nav.infoTab aria-label="Information"
        .nav.nav-tabs.nav-fill.justify-content-center#nav-tabs role="tablist"
          a.nav-item.nav-link#info-tab href="#{repository.decorate.show_path}" role="tab" aria-controls="info" aria-selected="false"
            i.fas.fa-info-circle
            ' Info
          - if repository.readme
            .nav-item.nav-link.active#readme-tab role="tab" aria-controls="readme" aria-selected="true"
              i.fas.fa-book
              ' Readme

      .tab-content.mt-4
        .tab-pane.show.active#readme role="tabpanel" aria-labelledby="readme-tab"
          .row
            .col-md-12.shard__readme
              == readme_html

    == render "src/views/repositories/_statistics.slang"
