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
require "time_by_example"
require "autolink"
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
  if id = env.session.bigint?("user_id")
    Admin.find(id)
  end
rescue
  nil
end

Kemal.config.add_handler(Raven::Kemal::ExceptionHandler.new)

static_headers do |response, _filepath, _filestat|
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
  Config.config.query = URI.decode_www_form(env.request.query_params["query"]?.to_s)
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
      .with_counts
      .with_user
      .with_tags
      .where { users.ignore == false }
      .where { repositories.ignore == false }
      .where { repositories.last_activity_at > 1.week.ago }
      .order_by(stars_count: :desc)
      .order_by("repositories.id", :asc)
      .limit(20)

  recently_repositories =
    Repository
      .query
      .join("users") { users.id == repositories.user_id }
      .with_counts
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

get "/repositories" do |env|
  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 20
  offset = (page - 1) * per_page

  raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

  sort_param = env.params.query["sort"]? || "stars"

  sort = sort_param.in?(Helpers::REPOSITORIES_SORT_OPTIONS.keys) ? sort_param : "stars"

  expression, direction = Helpers.repositories_sort_expression_direction(sort)

  repositories_query =
    Repository
      .query
      .with_tags
      .with_user
      .with_counts
      .published
      .order_by(expression, direction)
      .order_by("repositories.id", :asc)

  total_count = repositories_query.count

  raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

  paginator = ViewHelpers::Paginator.new(
    page,
    per_page,
    total_count,
    "/repositories?page=%{page}"
  ).to_s

  repositories = repositories_query.limit(per_page).offset(offset)

  Config.config.page_title = "All Shards"
  Config.config.page_description = "All Shards"

  render "src/views/repositories/index.slang", "src/views/layouts/layout.slang"
end

get "/users" do |env|
  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 20
  offset = (page - 1) * per_page

  raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

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

  raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

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

    raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

    query = env.params.query["query"].as(String)
    query = URI.decode_www_form(env.params.query["query"].as(String))

    # remove dissallowed tsquery characters
    query = query.gsub(/['?\\:‘’]/, "")
    query = URI.decode(query)

    repositories_query =
      Repository
        .query
        .with_tags
        .with_user
        .with_counts
        .published
        .search(query)
        .order_by(stars_count: :desc)
        .order_by("repositories.id", :asc)

    total_count = repositories_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

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

  if user = User.query.with_repositories(&.with_tags).find({provider: provider, login: owner})
    repositories =
      user
        .repositories
        .with_user
        .with_tags
        .with_counts
        .order_by(stars_count: :desc)

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

  if repository = Repository.find_repository(owner, repo, provider)
    dependencies =
      repository
        .dependencies
        .with_user
        .where { relationships.development == false }
        .with_counts

    development_dependencies =
      repository
        .dependencies
        .with_user
        .where { relationships.development == true }
        .with_counts

    dependents =
      repository
        .dependents
        .clear_distinct
        .with_user
        .with_counts
        .order_by("repositories.stars_count", :desc)
        .order_by("repositories.id", :asc)

    forks = repository.forks.with_user

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

  if repository = Repository.find_repository(owner, repo, provider)
    readme_html =
      if readme_content = repository.readme
        Helpers.to_markdown(repository, readme_content)
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

  route_path = "/#{provider}/#{owner}/#{repo}/dependents"

  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 20
  offset = (page - 1) * per_page

  raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

  sort_param = env.params.query["sort"]? || "stars"

  sort = sort_param.in?(Helpers::REPOSITORIES_SORT_OPTIONS.keys) ? sort_param : "stars"

  expression, direction = Helpers.repositories_sort_expression_direction(sort)

  if repository = Repository.find_repository(owner, repo, provider)
    repositories_query =
      repository
        .dependents
        .clear_distinct
        .with_tags
        .with_user
        .with_counts
        .order_by(expression, direction)
        .order_by("repositories.id", :asc)

    total_count = repositories_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

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
  name = env.params.url["name"]

  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 20
  offset = (page - 1) * per_page

  raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

  if tag = Tag.query.find({name: name})
    repositories_query =
      tag
        .repositories
        .join("users") { users.id == repositories.user_id }
        .clear_distinct
        .with_tags
        .with_user
        .where { users.ignore == false }
        .where { repositories.ignore == false }
        .with_counts
        .order_by("repositories.stars_count", :desc)
        .order_by("repositories.id", :asc)

    total_count = repositories_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/tags/#{name}?page=%{page}"
    ).to_s

    repositories = repositories_query.limit(per_page).offset(offset)

    Config.config.page_title = "Repositories tagged with '#{name}'"
    Config.config.page_description = "Crystal repositories with tag '#{name}'"

    render "src/views/tags/show.slang", "src/views/layouts/layout.slang"
  else
    raise Kemal::Exceptions::RouteNotFound.new(env)
  end
end

get "/languages" do |env|
  languages_json = CACHE.fetch("languages_json") do
    languages =
      Language
        .query
        .join("repository_languages") { var("repository_languages", "language_id") == var("languages", "id") }
        .select(
          "languages.*",
          "COUNT(repository_languages.*) AS languages_count"
        )
        .order_by(languages_count: :desc)
        .group_by("languages.id")

    languages_array = [] of Hash(String, String)

    languages.each(fetch_columns: true) do |language|
      languages_array << {
        "text"   => language.name.to_s,
        "weight" => language.attributes["languages_count"].to_s,
        "link"   => "/languages/#{language.name}",
        "color"  => language.color.to_s,
      }
    end

    languages_array.to_json
  end

  Config.config.page_title = "Languages on shards.info"
  Config.config.page_description = "Browse languages on shards.info"
  Config.config.current_page = "languages"

  render "src/views/languages/index.slang", "src/views/layouts/layout.slang"
end

get "/languages/:name" do |env|
  name = env.params.url["name"]
  name = URI.decode(name)

  if language = Linguist::Language.find_by_name(name)
    name = language.name
  end

  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 20
  offset = (page - 1) * per_page

  raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

  if language = Language.query.find({name: name})
    repositories_query =
      language
        .repositories
        .join("users") { users.id == repositories.user_id }
        .clear_distinct
        .with_tags
        .with_user
        .with_counts
        .order_by("repositories.stars_count", :desc)
        .order_by("repositories.id", :asc)

    total_count = repositories_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/languages/#{name}?page=%{page}"
    ).to_s

    repositories = repositories_query.limit(per_page).offset(offset)

    Config.config.page_title = "Repositories with language #{name}"
    Config.config.page_description = "Crystal repositories with language #{name}"

    render "src/views/languages/show.slang", "src/views/layouts/layout.slang"
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

  raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

  admin_query = Admin.query.order_by(created_at: :desc)

  total_count = admin_query.count

  raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

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

  if repository = Helpers.sync_repository_by_url(url)
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

  raise Kemal::Exceptions::RouteNotFound.new(env) if page < 1

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

  raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

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
    "/admin/hidden_repositories&page=%{page}"
  ).to_s

  repositories = repositories_query.limit(per_page).offset(offset)

  Config.config.page_title = "Admin: Hidden Repositories"

  render "src/views/admin/hidden_repositories/index.slang", "src/views/layouts/layout.slang"
end

post "/admin/users/:id/sync" do |env|
  id = env.params.url["id"]

  if user = User.find(id)
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

  if user = User.find(id)
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

  if user = User.find(id)
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

  if user = User.find(id)
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

  if repository = Repository.find(id)
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

  if repository = Repository.find(id)
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

  if repository = Repository.find(id)
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

  if repository = Repository.find(id)
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

get "/stats" do |env|
  repositories_count = Repository.query.count
  repositories_count_in_last_month = Repository.query.where("created_at >= NOW() - INTERVAL '28 days'").count

  users_count = User.query.count

  Config.config.page_title = "State of the Crystal shards ecosystem // shards.info"
  Config.config.page_description = "Crystal shards and repositories ecosystem statistics"

  render "src/views/stats.slang", "src/views/layouts/layout.slang"
end

get "/stats/created_at" do |env|
  repositiries =
    Repository
      .query
      .select(
        "date_trunc('month', created_at)::date as year_month",
        "count(*) as count"
      )
      .group_by("year_month")
      .order_by("year_month", :asc)

  hsh = {} of String => Int64

  repositiries.each(fetch_columns: true) do |repository|
    hsh[repository["year_month"].as(Time).to_s("%Y-%m")] = repository["count"].as(Int64)
  end

  hsh.to_json
end

get "/stats/last_activity_at" do |env|
  repositiries =
    Repository
      .query
      .select(
        "date_trunc('month', last_activity_at)::date as year_month",
        "count(*) as count"
      )
      .group_by("year_month")
      .order_by("year_month", :asc)

  hsh = {} of String => Int64

  repositiries.each(fetch_columns: true) do |repository|
    hsh[repository["year_month"].as(Time).to_s("%Y-%m")] = repository["count"].as(Int64)
  end

  hsh.to_json
end

get "/stats/repositories_growth" do |env|
  # Calculates the cumulative count of repositories created before and on each year-month date,
  # including months with no repositories
  CACHE.fetch("stats_repositories_growth", expires_in: 2.hours) do
    hsh = {} of String => Int64

    # https://github.com/crystal-lang/crystal was created on November 27, 2012
    date_start = "2012-11-01"

    month_series = Clear::SQL.select(<<-SQL
      generate_series(
        '#{date_start}'::date,
        (SELECT date_trunc('month', MAX(created_at)) FROM repositories),
        '1 month'::interval
      )::date AS year_month
      SQL
    )

    Clear::SQL
      .select({
        cumulative_count: "(SELECT COUNT(*) FROM repositories WHERE date_trunc('month', created_at)::date <= ms.year_month)",
        year_month:       "ms.year_month",
      })
      .with_cte({month_series: month_series})
      .from("month_series ms")
      .order_by("ms.year_month")
      .fetch do |hash|
        hsh[hash["year_month"].as(Time).to_s("%Y-%m")] = hash["cumulative_count"].as(Int64)
      end

    hsh.to_json
  end
end

# Number of direct dependencies
get "/stats/direct_dependencies" do |env|
  hsh = {} of Int64 => Int64

  Clear::SQL
    .select(
      "dependency_count",
      "COUNT(*) AS repository_count"
    )
    .from(<<-SQL
      (
        SELECT
          r.id,
          COUNT(rel.id) AS dependency_count
        FROM
          repositories r
        LEFT JOIN
          relationships rel ON r.id = rel.master_id
        GROUP BY
          r.id
      ) AS repo_dependency_count
      SQL
    )
    .group_by("dependency_count")
    .order_by("dependency_count", :asc)
    .fetch do |hash|
      hsh[hash["dependency_count"].as(Int64)] = hash["repository_count"].as(Int64)
    end

  hsh.to_json
end

# Number of transitive reverse dependencies
get "/stats/reverse_dependencies" do |env|
  hsh = {} of String => Int64

  Clear::SQL
    .select(
      "
      CASE
        WHEN dependency_count BETWEEN 1 AND 29 THEN dependency_count::text
        WHEN dependency_count BETWEEN 30 AND 100 THEN CONCAT((dependency_count / 10) * 10, '-', (dependency_count / 10) * 10 + 9)
        ELSE CONCAT((dependency_count / 100) * 100, '-', (dependency_count / 100) * 100 + 99)
      END AS dependency_range
      ",
      "COUNT(*) AS repository_count"
    )
    .from(<<-SQL
    (
      SELECT
        r.id,
        COUNT(rel.id) AS dependency_count
      FROM
        repositories r
      LEFT JOIN
        relationships rel ON r.id = rel.dependency_id
      GROUP BY
        r.id
    ) AS repo_dependency_count
    SQL
    )
    .group_by("dependency_range")
    .order_by("MIN(dependency_count)")
    .where("dependency_count > 0")
    .fetch do |hash|
      hsh[hash["dependency_range"].as(String)] = hash["repository_count"].as(Int64)
    end

  hsh.to_json
end

get "/stats/user_repositories_count" do |env|
  hsh = {} of Int64 => Int64

  Clear::SQL
    .select(
      "repo_count",
      "COUNT(*) AS user_count"
    )
    .from(<<-SQL
      (
        SELECT
          user_id,
          COUNT(*) AS repo_count
        FROM
          repositories
        GROUP BY
          user_id
      ) AS user_repos
      SQL
    )
    .group_by("repo_count")
    .order_by("repo_count")
    .fetch do |hash|
      hsh[hash["repo_count"].as(Int64)] = hash["user_count"].as(Int64)
    end

  hsh.to_json
end

Kemal.run
