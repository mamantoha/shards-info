.search-wrap
  form
    .form-group
      input class="form-control form-control-lg" type="text" placeholder="Search shards..."
      input type="submit" value="⌕" class="search-icon" data-disable-with="⌕"

ul class="nav nav-tabs" id="reposTab" role="tablist"
  li class="nav-item"
    a class="nav-link active" id="popular-tab" href="#popular" role="tab" data-toggle="tab" aria-controls="popular" aria-selected="true"
      i class="fas fa-fire"
      ' Most popular
  li class="nav-item"
    a class="nav-link" id="recently-tab" href="#recently" role="tab" data-toggle="tab" aria-controls="recently" aria-selected="false"
      i class="fas fa-clock"
      ' Recently updated

div class="tab-content"
  div role="tabpanel" class="tab-pane fade show active" id="popular" aria-labelledby="popular-tab"
    - repos = popular_repos
    == render "src/views/partials/repos.slang"
 div role="tabpanel" class="tab-pane fade" id="recently" aria-labelledby="recently-tab"
    - repos = recently_repos
    == render "src/views/partials/repos.slang"
