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

  nav id="reposTab" aria-label="Repositories"
    div class="nav nav-tabs nav-fill justify-content-center" id="nav-tabs" role="tablist"
      a class="nav-item nav-link active" id="trending-tab" href="#trending" role="tab" data-toggle="tab" aria-controls="trending" aria-selected="true"
        i class="fas fa-fire"
        ' Trending
      a class="nav-item nav-link" id="recently-tab" href="#recently" role="tab" data-toggle="tab" aria-controls="recently" aria-selected="false"
        i class="fas fa-clock"
        ' Recent

  div class="tab-content"
    div role="tabpanel" class="tab-pane fade show active" id="trending" aria-labelledby="trending-tab"
      - repositories = trending_repositories
      == render "src/views/repositories/_list.slang"
    div role="tabpanel" class="tab-pane fade" id="recently" aria-labelledby="recently-tab"
      - repositories = recently_repositories
      == render "src/views/repositories/_list.slang"
