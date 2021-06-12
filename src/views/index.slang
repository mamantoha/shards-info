== render "src/views/partials/subnav.slang"
div
  h1.page__heading
    .container.text-center.home_heaeding__container
      .h1
        ' Repositories
      .h6.font-weight-light
        ' See what the Crystal community is most excited about today

.container.home_repositories__container
  h1 style="display: none;" Trending Crystal repositories

  / Nav tab
  ul.nav.nav-tabs.nav-fill.justify-content-center#reposTab role="tablist" aria-label="Repositories"
    li.nav-item role="presentation"
      a.nav-link.active#trending-tab data-bs-toggle="tab" data-bs-target="#trending" href="#trending" type="button" role="tab" aria-controls="trending" aria-selected="true"
        i.fas.fa-fire
        ' Trending
    li.nav-item role="presentation"
      a.nav-link#recently-tab data-bs-toggle="tab" data-bs-target="#recently" href="#recently" type="button" role="tab" aria-controls="recently" aria-selected="false"
        i.fas.fa-clock
        ' Recent

  / Tab panes
  .tab-content.mt-4
    .tab-pane.fade.show.active#trending role="tabpanel" aria-labelledby="trending-tab"
      - repositories = trending_repositories
      == render "src/views/repositories/_list.slang"
    .tab-pane.fade#recently role="tabpanel" aria-labelledby="recently-tab"
      - repositories = recently_repositories
      == render "src/views/repositories/_list.slang"
