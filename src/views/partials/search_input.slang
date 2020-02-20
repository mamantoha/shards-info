.search-wrap
  div class="form-group has-search"
    span class="fa fa-search form-control-feedback"
    form#search class="navbar-form navbar-left" action="/search" method="GET" autocomplete="off"
      input aria-label="Search" name="query" type="search" class="form-control ms-sm-2" placeholder="Search shards..." onClick="this.select();" value="#{Config.config.query}"
