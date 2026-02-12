router = Kemal::Router.new

router.namespace "/admin" do
  before do |env|
    unless (current_user = current_user(env)) && current_user.admin?
      halt env, status_code: 403, response: "Forbidden"
    end
  end

  get "/" do |env|
    request_context = env.get("request_context").as(RequestContext)
    request_context.page_title = "Admin:"
    env.set "request_context", request_context

    render "src/views/admin/index.slang", "src/views/layouts/layout.slang"
  end

  get "/admins" do |env|
    page = env.params.query["page"]? || ""
    page = page.to_i? || 1
    per_page = 20
    offset = (page - 1) * per_page

    raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

    admin_query = Admin.query.order_by(created_at: :desc)

    total_count = admin_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/admins&page=#{page}"
    ).to_s

    admins = admin_query.limit(per_page).offset(offset)

    set_request_context(env) do
      request_context.page_title = "Admin: Site Admins"
    end

    render "src/views/admin/admins/index.slang", "src/views/layouts/layout.slang"
  end

  get "/repositories/new" do |env|
    set_request_context(env) do
      request_context.page_title = "Admin: Add new repository"
    end

    render "src/views/admin/repositories/new.slang", "src/views/layouts/layout.slang"
  end

  post "/repositories" do |env|
    url = env.params.body["repository[url]"].as(String)

    if repository = Helpers.sync_repository_by_url(url)
      env.flash["notice"] = "Repository was successfully added."

      env.redirect(repository.decorate.show_path)
    else
      env.flash["notice"] = "Something went wrong."

      env.redirect("/admin/repositories/new")
    end
  end

  get "/hidden_users" do |env|
    page = env.params.query["page"]? || ""
    page = page.to_i? || 1
    per_page = 20
    offset = (page - 1) * per_page

    raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

    users_query =
      User
        .query
        .join(:repositories)
        .where { users.ignore == true }
        .select(
          "users.*",
          "COUNT(repositories.*) AS repositories_count",
        )
        .group_by("users.id")

    total_count = users_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/hidden_users&page=#{page}"
    ).to_s

    users = users_query.limit(per_page).offset(offset)

    set_request_context(env) do
      request_context.page_title = "Admin: Hidden Users"
    end

    render "src/views/admin/hidden_users/index.slang", "src/views/layouts/layout.slang"
  end

  get "/hidden_repositories" do |env|
    page = env.params.query["page"]? || ""
    page = page.to_i? || 1
    per_page = 20
    offset = (page - 1) * per_page

    raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

    repositories_query =
      Repository
        .query
        .with_user
        .where { repositories.ignore == true }
        .order_by(stars_count: :desc)

    total_count = repositories_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/hidden_repositories&page=#{page}"
    ).to_s

    repositories = repositories_query.limit(per_page).offset(offset)

    set_request_context(env) do
      request_context.page_title = "Admin: Hidden Repositories"
    end

    render "src/views/admin/hidden_repositories/index.slang", "src/views/layouts/layout.slang"
  end

  get "/active_users" do |env|
    keys = ACTIVE_USERS_CACHE.keys

    set_request_context(env) do
      request_context.page_title = "Admin: Active Users"
    end

    render "src/views/admin/active_users/index.slang", "src/views/layouts/layout.slang"
  end

  post "/users/:id/sync" do |env|
    id = env.params.url["id"]

    if user = User.find(id)
      user.resync!

      env.flash["notice"] = "User was successfully synced."

      env.json({
        "status" => "success",
        "data"   => {
          "redirect_url" => "/#{user.provider}/#{user.login}",
        },
      })
    end
  end

  delete "/users/:id" do |env|
    id = env.params.url["id"]

    if user = User.find(id)
      user.delete

      env.flash["notice"] = "User was successfully destroyed."

      env.json({
        "status" => "success",
        "data"   => {
          "redirect_url" => "/",
        },
      })
    end
  end

  post "/users/:id/show" do |env|
    id = env.params.url["id"]

    if user = User.find(id)
      user.update(ignore: false)

      env.flash["notice"] = "User was successfully shown."

      env.json({
        "status" => "success",
        "data"   => {
          "redirect_url" => "/#{user.provider}/#{user.login}",
        },
      })
    end
  end

  post "/users/:id/hide" do |env|
    id = env.params.url["id"]

    if user = User.find(id)
      user.update(ignore: true)

      env.flash["notice"] = "User was successfully hidden."

      env.json({
        "status" => "success",
        "data"   => {
          "redirect_url" => "/#{user.provider}/#{user.login}",
        },
      })
    end
  end

  post "/repositories/:id/sync" do |env|
    id = env.params.url["id"]

    if repository = Repository.find(id)
      repository.resync!

      env.flash["notice"] = "Repository was successfully synced."

      env.json({
        "status" => "success",
        "data"   => {
          "redirect_url" => "/#{repository.provider}/#{repository.user.login}/#{repository.name}",
        },
      })
    end
  end

  post "/repositories/:id/show" do |env|
    id = env.params.url["id"]

    if repository = Repository.find(id)
      repository.update(ignore: false)

      env.flash["notice"] = "Repository was successfully shown."

      env.json({
        "status" => "success",
        "data"   => {
          "redirect_url" => "/#{repository.provider}/#{repository.user.login}/#{repository.name}",
        },
      })
    end
  end

  post "/repositories/:id/hide" do |env|
    id = env.params.url["id"]

    if repository = Repository.find(id)
      repository.update(ignore: true)

      env.flash["notice"] = "Repository was successfully hidden."

      env.json({
        "status" => "success",
        "data"   => {
          "redirect_url" => "/#{repository.provider}/#{repository.user.login}/#{repository.name}",
        },
      })
    end
  end

  delete "/repositories/:id" do |env|
    id = env.params.url["id"]

    if repository = Repository.find(id)
      repository.delete

      env.flash["notice"] = "Repository was successfully destroyed."

      env.json({
        "status" => "success",
        "data"   => {
          "redirect_url" => "/",
        },
      })
    end
  end
end

mount router
