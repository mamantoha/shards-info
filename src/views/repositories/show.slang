== render "src/views/repositories/_header.slang"

.container
  .row
    .col-md-8.col-sm-12.shard__main
      nav.infoTab aria-label="Information"
        .nav.nav-tabs.nav-fill.justify-content-center#nav-tabs role="tablist"
          .nav-item.nav-link.active#info-tab role="tab" aria-controls="info" aria-selected="true"
            i.fas.fa-info-circle
            ' Info
          a.nav-item.nav-link#readme-tab href="#{repository.decorate.readme_path}" role="tab" aria-controls="readme" aria-selected="false"
            i.fas.fa-book
            ' Readme

      .tab-content.mt-4
        .tab-pane.fade.show.active#info role="tabpanel" aria-labelledby="info-tab"
          == render "src/views/repositories/_info.slang"

    == render "src/views/repositories/_statistics.slang"
