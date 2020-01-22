h1 style="display: none;" Trending Crystal shards

ul class="nav nav-tabs nav-fill justify-content-center" id="reposTab" role="tablist"
  li class="nav-item"
    a class="nav-link active" id="trending-tab" href="#trending" role="tab" data-toggle="tab" aria-controls="trending" aria-selected="true"
      i class="fas fa-fire"
      ' Trending
  li class="nav-item"
    a class="nav-link" id="recently-tab" href="#recently" role="tab" data-toggle="tab" aria-controls="recently" aria-selected="false"
      i class="fas fa-clock"
      ' Recent
div class="tab-content"
  div role="tabpanel" class="tab-pane fade show active" id="trending" aria-labelledby="trending-tab"
    - repositories = trending_repositories
    == render "src/views/repositories/_list.slang"
  div role="tabpanel" class="tab-pane fade" id="recently" aria-labelledby="recently-tab"
    - repositories = recently_repositories
    == render "src/views/repositories/_list.slang"
