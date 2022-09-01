require "dotenv"
Dotenv.load?

require "shards_spec"

require "yaml"
require "base64"

require "compress/deflate"
require "compress/gzip"
require "compress/zlib"

require "kilt/slang"
require "crest"
require "emoji"
require "humanize_time"
require "autolink"
require "shards_spec"
require "raven"
require "raven/integrations/kemal"

require "../config/config"
require "./config"
require "./view_helpers"
require "./delegators"

require "./lib/cmark/readme_renderer"

def self.multi_auth(env)
  provider = env.params.url["provider"]
  redirect_uri = "#{Kemal.config.scheme}://#{env.request.headers["Host"]?}/auth/#{provider}/callback"
  MultiAuth.make(provider, redirect_uri)
end

def self.current_user(env) : Admin?
  if (id = env.session.bigint?("user_id"))
    Admin.find(id)
  end
end

Raven.configure do |config|
  config.async = true
  config.environments = %w(production)
  config.current_environment = ENV.fetch("KEMAL_ENV", "development")
  config.connect_timeout = 5.seconds
  config.read_timeout = 5.seconds
end

Kemal.config.add_handler(Raven::Kemal::ExceptionHandler.new)

static_headers do |response, filepath, filestat|
  duration = 1.day.total_seconds.to_i
  response.headers.add "Cache-Control", "public, max-age=#{duration}"
end

before_all "/admin/*" do |env|
  next if (current_user = current_user(env)) && current_user.admin?

  halt env, status_code: 403, response: "Forbidden"
end

before_all do |env|
  Config.config.open_graph = OpenGraph.new
  Config.config.open_graph.url = "https://shards.info#{env.request.path}"
  Config.config.query = env.request.query_params["query"]?.to_s
end

get "/auth/:provider" do |env|
  origin = env.request.headers["Referer"]? || "/"
  env.session.string("origin", origin)

  env.redirect(multi_auth(env).authorize_uri)
end

get "/auth/:provider/callback" do |env|
  user = multi_auth(env).user(env.params.query)

  admin = Admin.query.find({provider: user.provider, uid: user.uid}) || Admin.new({role: 0})

  admin.set({
    provider:   user.provider,
    uid:        user.uid,
    raw_json:   user.raw_json,
    name:       user.name,
    email:      user.email,
    nickname:   user.nickname,
    first_name: user.first_name,
    last_name:  user.last_name,
    location:   user.location,
    image:      user.image,
    phone:      user.phone,
  })

  if admin.save
    env.session.bigint("user_id", admin.id)
  end

  origin = env.session.string?("origin") || "/"

  env.redirect(origin)
end

get "/logout" do |env|
  env.session.destroy

  env.redirect "/"
end

error 404 do
  render "src/views/404.slang"
end

get "/" do |env|
  trending_repositories =
    Repository
      .query
      .join("users") { users.id == repositories.user_id }
      .with_user
      .with_tags
      .where { users.ignore == false }
      .where { repositories.ignore == false }
      .where { repositories.last_activity_at > 1.week.ago }
      .order_by(stars_count: :desc)
      .limit(20)

  recently_repositories =
    Repository
      .query
      .join("users") { users.id == repositories.user_id }
      .with_user
      .with_tags
      .where { users.ignore == false }
      .where { repositories.ignore == false }
      .order_by(last_activity_at: :desc)
      .limit(20)

  Config.config.page_title = "shards.info"
  Config.config.page_description = "See what the Crystal community is most excited about today"
  Config.config.current_page = "home"

  render "src/views/index.slang", "src/views/layouts/layout.slang"
end

get "/users" do |env|
  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 30
  offset = (page - 1) * per_page

  users_query =
    User
      .query
      .join("repositories") { var("repositories", "user_id") == var("users", "id") }
      .where { users.ignore == false }
      .where { repositories.ignore == false }
      .select(
        "users.*",
        "SUM(repositories.stars_count * CASE
          WHEN repositories.last_activity_at > '#{1.year.ago}' THEN 1
          ELSE 0.25
        END
        ) AS stars_count",
        "COUNT(repositories.*) AS repositories_count",
      )
      .group_by("users.id")
      .order_by(stars_count: :desc)

  total_count = users_query.count

  paginator = ViewHelpers::Paginator.new(
    page,
    per_page,
    total_count,
    "/users?page=%{page}"
  ).to_s

  users = users_query.limit(per_page).offset(offset)

  Config.config.page_title = "Crystal developers"
  Config.config.page_description = "Crystal developers"
  Config.config.current_page = "users"

  render "src/views/users/index.slang", "src/views/layouts/layout.slang"
end

get "/tags" do |env|
  skipped_tags = [
    "crystal", "crystal-language", "crystallang", "crystal-lang", "crystal-shard", "crystal-shards",
    "shard", "shards",
  ]

  tags_json = CACHE.fetch("tags_json") do
    tags =
      Tag
        .query
        .where { ~(name.in? skipped_tags) }
        .join("repository_tags") { repository_tags.tag_id == var("tags", "id") }
        .group_by("tags.id")
        .order_by(tagging_count: :desc)
        .limit(200)
        .select(
          "tags.*",
          "COUNT(repository_tags.*) AS tagging_count"
        )

    tags_array = [] of Hash(String, String)

    tags.each(fetch_columns: true) do |tag|
      tags_array << {
        "text"   => tag.name.to_s,
        "weight" => tag.attributes["tagging_count"].to_s,
        "link"   => "/tags/#{tag.name}",
      }
    end

    tags_array.to_json
  end

  Config.config.page_title = "Tags on shards.info"
  Config.config.page_description = "Browse popular tags on shards.info"
  Config.config.current_page = "tags"

  render "src/views/tags/index.slang", "src/views/layouts/layout.slang"
end

get "/search" do |env|
  if env.params.query.[]?("query").nil? || env.params.query.[]?("query").try(&.empty?)
    env.redirect "/"
  else
    page = env.params.query["page"]? || ""
    page = page.to_i? || 1
    per_page = 20
    offset = (page - 1) * per_page

    query = env.params.query["query"].as(String)

    # remove dissallowed tsquery characters
    query = query.gsub(/['?\\:‘’]/, "")

    repositories_query =
      Repository
        .query
        .with_tags
        .with_user
        .published
        .search(query)
        .order_by(stars_count: :desc)

    total_count = repositories_query.count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/search?query=#{query}&page=%{page}"
    ).to_s

    repositories = repositories_query.limit(per_page).offset(offset)

    Config.config.page_title = "Search for '#{query}'"
    Config.config.page_description = "Search Crystal repositories for '#{query}'"

    render "src/views/search/index.slang", "src/views/layouts/layout.slang"
  end
end

get "/:provider/:owner" do |env|
  provider = env.params.url["provider"]
  owner = env.params.url["owner"]

  if (user = User.query.with_repositories(&.with_tags).find({provider: provider, login: owner}))
    repositories = user.repositories.with_user.with_tags.order_by(stars_count: :desc)
    repositories_count = repositories.count

    Config.config.page_title = "#{user.login} Crystal repositories"
    Config.config.page_description = "#{user.login} has #{repositories_count} Crystal repositories"

    Config.config.open_graph.title = "#{user.login} (#{user.name})"
    Config.config.open_graph.description = "#{user.login} has #{repositories_count} Crystal repositories"
    Config.config.open_graph.image = "#{user.decorate.avatar}"
    Config.config.open_graph.type = "profile"

    render "src/views/users/show.slang", "src/views/layouts/layout.slang"
  else
    raise Kemal::Exceptions::RouteNotFound.new(env)
  end
end

get "/:provider/:owner/:repo" do |env|
  provider = env.params.url["provider"]
  owner = env.params.url["owner"]
  repo = env.params.url["repo"]

  if (repository = Repository.find_repository(owner, repo, provider))
    dependencies =
      repository
        .dependencies
        .undistinct
        .with_user
        .where { relationships.development == false }
        .order_by({stars_count: :desc})

    development_dependencies =
      repository
        .dependencies
        .undistinct
        .with_user
        .where { relationships.development == true }
        .order_by({stars_count: :desc})

    dependents = repository.dependents.undistinct.order_by({stars_count: :desc})

    dependents_count = dependents.count

    Config.config.page_title = "#{repository.decorate.full_name}: #{repository.decorate.description_with_emoji}"
    Config.config.page_description = "#{repository.decorate.full_name}: #{repository.decorate.description_with_emoji}"
    Config.config.open_graph.title = "#{repository.decorate.full_name}"
    Config.config.open_graph.description = "#{repository.decorate.description_with_emoji}"
    Config.config.open_graph.image = "#{repository.user.avatar_url}"

    render "src/views/repositories/show.slang", "src/views/layouts/layout.slang"
  else
    raise Kemal::Exceptions::RouteNotFound.new(env)
  end
end

get "/:provider/:owner/:repo/readme" do |env|
  provider = env.params.url["provider"]
  owner = env.params.url["owner"]
  repo = env.params.url["repo"]

  if (repository = Repository.find_repository(owner, repo, provider))
    readme_html =
      if repository.readme
        Helpers.to_markdown(repository)
      else
        raise Kemal::Exceptions::RouteNotFound.new(env)
      end

    Config.config.page_title = "#{repository.decorate.full_name}: #{repository.decorate.description_with_emoji}"
    Config.config.page_description = "#{repository.decorate.full_name}: #{repository.decorate.description_with_emoji}"
    Config.config.open_graph.title = "#{repository.decorate.full_name}"
    Config.config.open_graph.description = "#{repository.decorate.description_with_emoji}"
    Config.config.open_graph.image = "#{repository.user.avatar_url}"

    render "src/views/repositories/readme.slang", "src/views/layouts/layout.slang"
  else
    raise Kemal::Exceptions::RouteNotFound.new(env)
  end
end

get "/:provider/:owner/:repo/dependents" do |env|
  provider = env.params.url["provider"]
  owner = env.params.url["owner"]
  repo = env.params.url["repo"]

  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 20
  offset = (page - 1) * per_page

  if (repository = Repository.find_repository(owner, repo, provider))
    # TODO: Exception:  (Clear::SQL::RecordNotFoundError)
    # when calling with `.with_user` and limit/offset
    repositories_query =
      repository
        .dependents
        .undistinct
        .order_by({stars_count: :desc})

    total_count = repositories_query.count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/#{provider}/#{owner}/#{repo}/dependents?page=%{page}"
    ).to_s

    repositories = repositories_query.limit(per_page).offset(offset)

    Config.config.page_title = "Depend on '#{repository.decorate.full_name}'"
    Config.config.page_description = "Depend on '#{repository.decorate.full_name}'"

    render "src/views/dependents/index.slang", "src/views/layouts/layout.slang"
  else
    raise Kemal::Exceptions::RouteNotFound.new(env)
  end
end

get "/tags/:name" do |env|
  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 20
  offset = (page - 1) * per_page

  name = env.params.url["name"]

  if (tag = Tag.query.find({name: name}))
    repositories_query = tag.repositories

    total_count = repositories_query.count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/tags/#{name}?page=%{page}"
    ).to_s

    repositories =
      repositories_query
        .undistinct
        .with_tags
        .with_user
        .order_by(stars_count: :desc)
        .limit(per_page)
        .offset(offset)

    Config.config.page_title = "Repositories tagged with '#{name}'"
    Config.config.page_description = "Crystal repositories with tag '#{name}'"

    render "src/views/tags/show.slang", "src/views/layouts/layout.slang"
  else
    raise Kemal::Exceptions::RouteNotFound.new(env)
  end
end

get "/admin" do |env|
  Config.config.page_title = "Admin:"

  render "src/views/admin/index.slang", "src/views/layouts/layout.slang"
end

get "/admin/admins" do |env|
  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 20
  offset = (page - 1) * per_page

  admin_query = Admin.query.order_by(created_at: :desc)

  total_count = admin_query.count

  paginator = ViewHelpers::Paginator.new(
    page,
    per_page,
    total_count,
    "/admin/admins&page=%{page}"
  ).to_s

  admins = admin_query.limit(per_page).offset(offset)

  Config.config.page_title = "Admin: Site Admins"

  render "src/views/admin/admins/index.slang", "src/views/layouts/layout.slang"
end

get "/admin/repositories/new" do |env|
  Config.config.page_title = "Admin: Add new repository"

  render "src/views/admin/repositories/new.slang", "src/views/layouts/layout.slang"
end

post "/admin/repositories" do |env|
  url = env.params.body["repository[url]"].as(String)

  if (repository = Helpers.sync_repository_by_url(url))
    env.flash["notice"] = "Repository was successfully added."

    env.redirect(repository.decorate.show_path)
  else
    env.flash["notice"] = "Something went wrong."

    env.redirect("/admin/repositories/new")
  end
end

get "/admin/hidden_users" do |env|
  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 20
  offset = (page - 1) * per_page

  users_query =
    User
      .query
      .join("repositories") { var("repositories", "user_id") == var("users", "id") }
      .where { users.ignore == true }
      .select(
        "users.*",
        "COUNT(repositories.*) AS repositories_count",
      )
      .group_by("users.id")

  total_count = users_query.count

  paginator = ViewHelpers::Paginator.new(
    page,
    per_page,
    total_count,
    "/admin/hidden_users&page=%{page}"
  ).to_s

  users = users_query.limit(per_page).offset(offset)

  Config.config.page_title = "Admin: Hidden Users"

  render "src/views/admin/hidden_users/index.slang", "src/views/layouts/layout.slang"
end

get "/admin/hidden_repositories" do |env|
  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 20
  offset = (page - 1) * per_page

  repositories_query =
    Repository
      .query
      .with_user
      .where { repositories.ignore == true }
      .order_by(stars_count: :desc)

  total_count = repositories_query.count

  paginator = ViewHelpers::Paginator.new(
    page,
    per_page,
    total_count,
    "/admin/hidden_repositories&page=%{page}"
  ).to_s

  repositories = repositories_query.limit(per_page).offset(offset)

  Config.config.page_title = "Admin: Hidden Repositories"

  render "src/views/admin/hidden_repositories/index.slang", "src/views/layouts/layout.slang"
end

post "/admin/users/:id/sync" do |env|
  id = env.params.url["id"]

  if (user = User.find(id))
    case user.provider
    when "github"
      GithubHelpers.resync_user(user)
    when "gitlab"
      GitlabHelpers.resync_user(user)
    end

    env.response.content_type = "application/json"
    env.flash["notice"] = "User was successfully synced."

    {
      "status" => "success",
      "data"   => {
        "redirect_url" => "/#{user.provider}/#{user.login}",
      },
    }.to_json
  end
end

delete "/admin/users/:id" do |env|
  id = env.params.url["id"]

  if (user = User.find(id))
    user.delete

    env.response.content_type = "application/json"
    env.flash["notice"] = "User was successfully destroyed."

    {
      "status" => "success",
      "data"   => {
        "redirect_url" => "/",
      },
    }.to_json
  end
end

post "/admin/users/:id/show" do |env|
  id = env.params.url["id"]

  if (user = User.find(id))
    user.update(ignore: false)

    env.response.content_type = "application/json"
    env.flash["notice"] = "User was successfully shown."

    {
      "status" => "success",
      "data"   => {
        "redirect_url" => "/#{user.provider}/#{user.login}",
      },
    }.to_json
  end
end

post "/admin/users/:id/hide" do |env|
  id = env.params.url["id"]

  if (user = User.find(id))
    user.update(ignore: true)

    env.response.content_type = "application/json"
    env.flash["notice"] = "User was successfully hidden."

    {
      "status" => "success",
      "data"   => {
        "redirect_url" => "/#{user.provider}/#{user.login}",
      },
    }.to_json
  end
end

post "/admin/repositories/:id/sync" do |env|
  id = env.params.url["id"]

  if (repository = Repository.find(id))
    case repository.provider
    when "github"
      GithubHelpers.resync_repository(repository)
    when "gitlab"
      GitlabHelpers.resync_repository(repository)
    end

    env.response.content_type = "application/json"
    env.flash["notice"] = "Repository was successfully synced."

    {
      "status" => "success",
      "data"   => {
        "redirect_url" => "/#{repository.provider}/#{repository.user.login}/#{repository.name}",
      },
    }.to_json
  end
end

post "/admin/repositories/:id/show" do |env|
  id = env.params.url["id"]

  if (repository = Repository.find(id))
    repository.update(ignore: false)

    env.response.content_type = "application/json"
    env.flash["notice"] = "Repository was successfully shown."

    {
      "status" => "success",
      "data"   => {
        "redirect_url" => "/#{repository.provider}/#{repository.user.login}/#{repository.name}",
      },
    }.to_json
  end
end

post "/admin/repositories/:id/hide" do |env|
  id = env.params.url["id"]

  if (repository = Repository.find(id))
    repository.update(ignore: true)

    env.response.content_type = "application/json"
    env.flash["notice"] = "Repository was successfully hidden."

    {
      "status" => "success",
      "data"   => {
        "redirect_url" => "/#{repository.provider}/#{repository.user.login}/#{repository.name}",
      },
    }.to_json
  end
end

delete "/admin/repositories/:id" do |env|
  id = env.params.url["id"]

  if (repository = Repository.find(id))
    repository.delete

    env.response.content_type = "application/json"
    env.flash["notice"] = "Repository was successfully destroyed."

    {
      "status" => "success",
      "data"   => {
        "redirect_url" => "/",
      },
    }.to_json
  end
end

Kemal.run
