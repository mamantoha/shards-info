.subnav
  .container
    ul class="nav"
      li class="nav-item"
        a class="nav-link #{"active" if Config.config.current_page == "home"}" href="/" Repositories
      li class="nav-item"
        a class="nav-link #{"active" if Config.config.current_page == "users"}" href="/users" Community
      li class="nav-item"
        a class="nav-link #{"active" if Config.config.current_page == "tags"}" href="/tags" Tags
