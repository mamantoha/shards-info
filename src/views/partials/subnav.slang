== render "src/views/partials/swu_banner.ecr"

- request_context = env.get("request_context").as(RequestContext)

.subnav
  .container
    ul.nav
      li.nav-item
        a class="nav-link #{"active" if request_context.current_page == "home"}" href="/" Repositories
      li.nav-item
        a class="nav-link #{"active" if request_context.current_page == "users"}" href="/users" Community
      li.nav-item
        a class="nav-link #{"active" if request_context.current_page == "tags"}" href="/tags" Tags
      li.nav-item.d-none.d-lg-block
        a class="nav-link #{"active" if request_context.current_page == "languages"}" href="/languages" Languages
