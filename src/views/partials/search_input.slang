.search-wrap
  form class="navbar-form navbar-left" action="/repos" method="GET"
    input name="query" class="form-control ms-sm-2" type="search" onClick="this.select();" placeholder="Search shards..." value="#{Config.config.query}"
    button type="submit" class="search-icon"
      i class="fas fa-search"
