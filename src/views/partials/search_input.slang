.search-wrap
  div class="form-group has-search"
    span class="fa fa-search form-control-feedback"
    form.d-flex#search class="navbar-form navbar-left" action="/search" method="GET" autocomplete="off"
      input.form-control.me-2 aria-label="Search" name="query" type="search" placeholder="Search shards..." onClick="this.select();" value="#{Config.config.query}"
