private def visitor_id(env : HTTP::Server::Context) : UUID
  UUID.parse?(env.params.url["id"]) || raise Kemal::Exceptions::RouteNotFound.new(env)
end

private def database_activity
  monitoring_connection = "monitoring"
  pg_stat_activity_filter = "datname = current_database() AND pid <> pg_backend_pid()"

  database_size = Lustra::SQL
    .select("pg_size_pretty(pg_database_size(current_database()))")
    .use_connection(monitoring_connection)
    .scalar(String)

  activity_rows = Lustra::SQL
    .select
    .from("pg_stat_activity")
    .where(pg_stat_activity_filter)
    .order_by("query_start", :desc)
    .use_connection(monitoring_connection)
    .pluck(
      pid: Int32,
      state: String?,
      query_start: Time?,
      query: String?
    )

  activity_counts = {} of String => Int64
  activity_rows.each do |row|
    state = row[1] || "unknown"
    activity_counts[state] = (activity_counts[state]? || 0_i64) + 1
  end

  {database_size, activity_rows, activity_counts}
end

private def database_activity_json(database_size, activity_rows, activity_counts)
  {
    "database_size" => database_size,
    "counts"        => activity_counts.map do |state, count|
      {
        "state" => state,
        "count" => count,
      }
    end,
    "activity" => activity_rows.map do |row|
      {
        "pid"         => row[0],
        "state"       => row[1],
        "query_start" => row[2].try(&.to_rfc3339),
        "query"       => row[3],
      }
    end,
  }
end

router = Kemal::Router.new

router.namespace "/admin" do
  before do |env|
    unless current_admin?(env)
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
    per_page = 20
    page, offset = Helpers.pagination(env, per_page) || raise Kemal::Exceptions::RouteNotFound.new(env)

    admins =
      Admin
        .query
        .order_by(created_at: :desc)
        .order_by("admins.id", :asc)
        .paginate(page, per_page)

    total_count = admins.total_entries || 0_i64

    raise Kemal::Exceptions::RouteNotFound.new(env) if offset > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/admins&page=#{page}"
    ).to_s

    set_request_context(env) do
      request_context.page_title = "Admin: Site Admins"
    end

    render "src/views/admin/admins/index.slang", "src/views/layouts/layout.slang"
  end

  namespace "/repositories" do
    get "/new" do |env|
      set_request_context(env) do
        request_context.page_title = "Admin: Add new repository"
      end

      render "src/views/admin/repositories/new.slang", "src/views/layouts/layout.slang"
    end

    post "/" do |env|
      url = env.params.body["repository[url]"].as(String)

      if repository = Helpers.sync_repository_by_url(url)
        env.flash["notice"] = "Repository was successfully added."

        env.redirect(repository.decorate.show_path)
      else
        env.flash["notice"] = "Something went wrong."

        env.redirect("/admin/repositories/new")
      end
    end

    post "/:id/sync" do |env|
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

    post "/:id/show" do |env|
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

    post "/:id/hide" do |env|
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

    delete "/:id" do |env|
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

  get "/hidden_users" do |env|
    per_page = 20
    page, offset = Helpers.pagination(env, per_page) || raise Kemal::Exceptions::RouteNotFound.new(env)

    users =
      User
        .query
        .join(:repositories)
        .where { var("users", "ignore").true? }
        .select(
          "users.*",
          "COUNT(repositories.*) AS repositories_count",
        )
        .group_by("users.id")
        .order_by("users.id", :asc)
        .paginate(page, per_page)

    total_count = users.total_entries || 0_i64

    raise Kemal::Exceptions::RouteNotFound.new(env) if offset > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/hidden_users&page=#{page}"
    ).to_s

    set_request_context(env) do
      request_context.page_title = "Admin: Hidden Users"
    end

    render "src/views/admin/hidden_users/index.slang", "src/views/layouts/layout.slang"
  end

  get "/hidden_repositories" do |env|
    per_page = 20
    page, offset = Helpers.pagination(env, per_page) || raise Kemal::Exceptions::RouteNotFound.new(env)

    repositories =
      Repository
        .query
        .with_user
        .where { var("repositories", "ignore").true? }
        .order_by(stars_count: :desc)
        .order_by("repositories.id", :asc)
        .paginate(page, per_page)

    total_count = repositories.total_entries || 0_i64

    raise Kemal::Exceptions::RouteNotFound.new(env) if offset > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/hidden_repositories&page=#{page}"
    ).to_s

    set_request_context(env) do
      request_context.page_title = "Admin: Hidden Repositories"
    end

    render "src/views/admin/hidden_repositories/index.slang", "src/views/layouts/layout.slang"
  end

  get "/visitors" do |env|
    per_page = 20
    page, offset = Helpers.pagination(env, per_page) || raise Kemal::Exceptions::RouteNotFound.new(env)

    visitors =
      Visitor
        .query
        .order_by(updated_at: :desc)
        .paginate(page, per_page)

    total_count = visitors.total_entries || 0_i64

    raise Kemal::Exceptions::RouteNotFound.new(env) if offset > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/visitors?page=#{page}"
    ).to_s

    set_request_context(env) do
      request_context.page_title = "Admin: Visitors"
    end

    render "src/views/admin/visitors/index.slang", "src/views/layouts/layout.slang"
  end

  get "/visitors/:id" do |env|
    visitor_id = visitor_id(env)

    visitor = Visitor.find!(visitor_id)

    per_page = 20
    page, offset = Helpers.pagination(env, per_page) || raise Kemal::Exceptions::RouteNotFound.new(env)

    events =
      visitor
        .events
        .order_by(created_at: :desc)
        .order_by("events.id", :desc)
        .paginate(page, per_page)

    total_count = events.total_entries || 0_i64

    raise Kemal::Exceptions::RouteNotFound.new(env) if offset > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/admin/visitors/#{visitor.id}?page=#{page}"
    ).to_s

    set_request_context(env) do
      request_context.page_title = "Admin: Visitor #{visitor.id}"
    end

    render "src/views/admin/visitors/show.slang", "src/views/layouts/layout.slang"
  end

  post "/visitors/:id/delete" do |env|
    visitor_id = visitor_id(env)
    Visitor.find!(visitor_id).delete

    env.flash["notice"] = "Visitor was successfully deleted."
    env.redirect("/admin/visitors")
  end

  get "/database" do |env|
    database_size, activity_rows, activity_counts = database_activity

    set_request_context(env) do
      request_context.page_title = "Admin: Database"
    end

    render "src/views/admin/database/index.slang", "src/views/layouts/layout.slang"
  end

  get "/database.json" do |env|
    database_size, activity_rows, activity_counts = database_activity

    env.json(database_activity_json(database_size, activity_rows, activity_counts))
  end

  namespace "/users" do
    post "/:id/sync" do |env|
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

    delete "/:id" do |env|
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

    post "/:id/show" do |env|
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

    post "/:id/hide" do |env|
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
  end
end

mount router
