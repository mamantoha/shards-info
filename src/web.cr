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
require "time_duration"
require "time_zone"
require "countdown"
require "autolink"
require "raven/integrations/kemal"

require "../config/config"
require "./config"
require "./request_context"
require "./view_helpers"
require "./delegators"

require "./lib/cmark/readme_renderer"

add_handler Defense::Handler.new

add_context_storage_type(RequestContext)

def self.multi_auth(env) : MultiAuth::Engine?
  provider = env.params.url["provider"]
  redirect_uri = "#{Kemal.config.scheme}://#{env.request.headers["Host"]?}/auth/#{provider}/callback"
  MultiAuth.make(provider, redirect_uri) rescue nil
end

def self.current_user(env) : Admin?
  if id = env.session.bigint?("user_id")
    Admin.find(id)
  end
rescue
  nil
end

Kemal.config.add_handler(Raven::Kemal::ExceptionHandler.new)

static_headers do |env, _filepath, _filestat|
  duration = 1.day.total_seconds.to_i
  env.response.headers.add "Cache-Control", "public, max-age=#{duration}"
end

before_all do |env|
  if env.request.path.starts_with?("/admin")
    unless (current_user = current_user(env)) && current_user.admin?
      halt env, status_code: 403, response: "Forbidden"
    end
  end

  query = env.request.query_params["query"]?.to_s

  unless query.valid_encoding?
    query = query.scrub("")
  end

  query = URI.decode_www_form(query)

  RequestContext.new do |request_context|
    request_context.search_query = query
    request_context.open_graph.url = "https://shards.info#{env.request.path}"

    env.set "request_context", request_context
  end
end

get "/auth/:provider" do |env|
  origin = env.request.headers["Referer"]? || "/"
  env.session.string("origin", origin)

  if auth = multi_auth(env)
    env.redirect(auth.authorize_uri)
  else
    raise Kemal::Exceptions::RouteNotFound.new(env)
  end
end

get "/auth/:provider/callback" do |env|
  if auth = multi_auth(env)
    user = auth.user(env.params.query)
  else
    raise Kemal::Exceptions::RouteNotFound.new(env)
  end

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

get "/about" do |env|
  set_request_context(env) do
    request_context.page_title = "About"
    request_context.page_description = "About"
  end

  render "src/views/about.slang", "src/views/layouts/layout.slang"
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

  set_request_context(env) do
    request_context.page_description = "See what the Crystal community is most excited about today"
  end

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

  route_path = "/repositories?page=#{page}"

  paginator = ViewHelpers::Paginator.new(
    page,
    per_page,
    total_count,
    "/repositories?page=#{page}&sort=#{sort}"
  ).to_s

  repositories = repositories_query.limit(per_page).offset(offset)

  set_request_context(env) do
    request_context.page_title = "All Shards"
    request_context.page_description = "All Shards"
  end

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
    "/users?page=#{page}"
  ).to_s

  users = users_query.limit(per_page).offset(offset)

  set_request_context(env) do
    request_context.page_title = "Crystal developers"
    request_context.page_description = "Crystal developers"
    request_context.current_page = "users"
  end

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

  set_request_context(env) do
    request_context.page_title = "Tags"
    request_context.page_description = "Browse popular tags on shards.info"
    request_context.current_page = "tags"
  end

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

    sort_param = env.params.query["sort"]? || "stars"
    sort = sort_param.in?(Helpers::REPOSITORIES_SORT_OPTIONS.keys) ? sort_param : "stars"
    expression, direction = Helpers.repositories_sort_expression_direction(sort)

    query_param = env.params.query["query"].as(String)

    unless query_param.valid_encoding?
      query_param = query_param.scrub("")
    end

    query = URI.decode_www_form(query_param)

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
        .order_by(expression, direction)
        .order_by("repositories.id", :asc)

    total_count = repositories_query.count

    raise Kemal::Exceptions::RouteNotFound.new(env) if (page - 1) * per_page > total_count

    route_path = "/search?query=#{query_param}&page=#{page}"

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/search?query=#{query_param}&page=#{page}&sort=#{sort}"
    ).to_s

    repositories = repositories_query.limit(per_page).offset(offset)

    set_request_context(env) do
      request_context.page_title = "Search for '#{query}'"
      request_context.page_description = "Search Crystal repositories for '#{query}'"
    end

    render "src/views/search/index.slang", "src/views/layouts/layout.slang"
  end
end

get "/:provider/:owner" do |env|
  provider = env.params.url["provider"]
  owner = env.params.url["owner"]

  sort_param = env.params.query["sort"]? || "stars"
  sort = sort_param.in?(Helpers::REPOSITORIES_SORT_OPTIONS.keys) ? sort_param : "stars"
  expression, direction = Helpers.repositories_sort_expression_direction(sort)

  if user = User.query.with_repositories(&.with_tags).find({provider: provider, login: owner})
    repositories =
      user
        .repositories
        .with_user
        .with_tags
        .with_counts
        .order_by(expression, direction)
        .order_by("repositories.id", :asc)

    repositories_count = repositories.count

    route_path = "/#{user.provider}/#{user.login}?"

    set_request_context(env) do
      request_context.page_title = "#{user.login} Crystal repositories"
      request_context.page_description = "#{user.login} has #{repositories_count} Crystal repositories"
      request_context.open_graph.title = "#{user.login} (#{user.name})"
      request_context.open_graph.description = "#{user.login} has #{repositories_count} Crystal repositories"
      request_context.open_graph.image = "#{user.decorate.avatar}"
      request_context.open_graph.type = "profile"
    end

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

    # Forks sorted by dependents count
    forks =
      repository
        .forks
        .clear_distinct
        .with_user
        .with_counts
        .order_by(
          "(select COUNT(*) from relationships rel WHERE rel.dependency_id=repositories.id)",
          :desc
        )

    dependents_count = dependents.count

    set_request_context(env) do
      request_context.page_title = "#{repository.decorate.full_name}: #{repository.decorate.description_with_emoji}"
      request_context.page_description = "#{repository.decorate.full_name}: #{repository.decorate.description_with_emoji}"
      request_context.open_graph.title = "#{repository.decorate.full_name}"
      request_context.open_graph.description = "#{repository.decorate.description_with_emoji}"
      request_context.open_graph.image = "#{repository.user.avatar_url}"
    end

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

    set_request_context(env) do
      request_context.page_title = "#{repository.decorate.full_name}: #{repository.decorate.description_with_emoji}"
      request_context.page_description = "#{repository.decorate.full_name}: #{repository.decorate.description_with_emoji}"
      request_context.open_graph.title = "#{repository.decorate.full_name}"
      request_context.open_graph.description = "#{repository.decorate.description_with_emoji}"
      request_context.open_graph.image = "#{repository.user.avatar_url}"
    end

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

    route_path = "/#{provider}/#{owner}/#{repo}/dependents?page=#{page}"

    paginator = ViewHelpers::Paginator.new(
      page,
      per_page,
      total_count,
      "/#{provider}/#{owner}/#{repo}/dependents?page=#{page}&sort=#{sort}"
    ).to_s

    repositories = repositories_query.limit(per_page).offset(offset)

    set_request_context(env) do
      request_context.page_title = "Depend on '#{repository.decorate.full_name}'"
      request_context.page_description = "Depend on '#{repository.decorate.full_name}'"
    end

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

    set_request_context(env) do
      request_context.page_title = "Repositories tagged with '#{name}'"
      request_context.page_description = "Crystal repositories with tag '#{name}'"
    end

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

  set_request_context(env) do
    request_context.page_title = "Languages on shards.info"
    request_context.page_description = "Browse languages on shards.info"
    request_context.current_page = "languages"
  end

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
      "/languages/#{name}?page=#{page}"
    ).to_s

    repositories = repositories_query.limit(per_page).offset(offset)

    set_request_context(env) do
      request_context.page_title = "Repositories with language #{name}"
      request_context.page_description = "Crystal repositories with language #{name}"
    end

    render "src/views/languages/show.slang", "src/views/layouts/layout.slang"
  else
    raise Kemal::Exceptions::RouteNotFound.new(env)
  end
end

get "/admin" do |env|
  request_context = env.get("request_context").as(RequestContext)
  request_context.page_title = "Admin:"
  env.set "request_context", request_context

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
    "/admin/admins&page=#{page}"
  ).to_s

  admins = admin_query.limit(per_page).offset(offset)

  set_request_context(env) do
    request_context.page_title = "Admin: Site Admins"
  end

  render "src/views/admin/admins/index.slang", "src/views/layouts/layout.slang"
end

get "/admin/repositories/new" do |env|
  set_request_context(env) do
    request_context.page_title = "Admin: Add new repository"
  end

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
    "/admin/hidden_users&page=#{page}"
  ).to_s

  users = users_query.limit(per_page).offset(offset)

  set_request_context(env) do
    request_context.page_title = "Admin: Hidden Users"
  end

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
    "/admin/hidden_repositories&page=#{page}"
  ).to_s

  repositories = repositories_query.limit(per_page).offset(offset)

  set_request_context(env) do
    request_context.page_title = "Admin: Hidden Repositories"
  end

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
  users_count = User.query.count

  repositories_count_in_last_month = Repository.query.where("created_at >= NOW() - INTERVAL '28 days'").count

  users_count = User.query.count

  set_request_context(env) do
    request_context.page_title = "State of the Crystal shards ecosystem // shards.info"
    request_context.page_description = "Crystal shards and repositories ecosystem statistics"
  end

  render "src/views/stats.slang", "src/views/layouts/layout.slang"
end

get "/stats/created_at" do |env|
  json = CACHE.fetch("stats:created_at", expires_in: 2.hours) do
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

  env.response.content_type = "application/json"
  json
end

get "/stats/last_activity_at" do |env|
  json = CACHE.fetch("stats:last_activity_at_json", expires_in: 2.hours) do
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

  env.response.content_type = "application/json"
  json
end

get "/stats/repositories_growth" do |env|
  # Calculates the cumulative count of repositories created before and on each year-month date,
  # including months with no repositories
  json = CACHE.fetch("stats:repositories_growth", expires_in: 2.hours) do
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
      .fetch do |attributes|
        hsh[attributes["year_month"].as(Time).to_s("%Y-%m")] = attributes["cumulative_count"].as(Int64)
      end

    hsh.to_json
  end

  env.response.content_type = "application/json"
  json
end

# Number of direct dependencies
get "/stats/direct_dependencies" do |env|
  json = CACHE.fetch("stats:direct_dependencies", expires_in: 2.hours) do
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
      .fetch do |attributes|
        hsh[attributes["dependency_count"].as(Int64)] = attributes["repository_count"].as(Int64)
      end

    hsh.to_json
  end

  env.response.content_type = "application/json"
  json
end

# Number of transitive reverse dependencies
get "/stats/reverse_dependencies" do |env|
  json = CACHE.fetch("stats:reverse_dependencies", expires_in: 2.hours) do
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
      .fetch do |attributes|
        hsh[attributes["dependency_range"].as(String)] = attributes["repository_count"].as(Int64)
      end

    hsh.to_json
  end

  env.response.content_type = "application/json"
  json
end

get "/stats/user_repositories_count" do |env|
  json = CACHE.fetch("stats:user_repositories_count", expires_in: 2.hours) do
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
      .fetch do |attributes|
        hsh[attributes["repo_count"].as(Int64)] = attributes["user_count"].as(Int64)
      end

    hsh.to_json
  end

  env.response.content_type = "application/json"
  json
end

get "/stats/repositories_provider_count" do |env|
  json = CACHE.fetch("stats:repositories_provider_count", expires_in: 2.hours) do
    hsh = {} of String => Int64

    Repository
      .query
      .select("provider, COUNT(*) AS count")
      .group_by("provider")
      .order_by(count: :desc)
      .each(fetch_columns: true) do |repository|
        hsh[repository.provider] = repository.attributes["count"].as(Int64)
      end

    hsh.to_json
  end

  env.response.content_type = "application/json"
  json
end

get "/stats/users_provider_count" do |env|
  json = CACHE.fetch("stats:users_provider_count", expires_in: 2.hours) do
    hsh = {} of String => Int64

    User
      .query
      .select("provider, COUNT(*) AS count")
      .group_by("provider")
      .order_by(count: :desc)
      .each(fetch_columns: true) do |user|
        hsh[user.provider] = user.attributes["count"].as(Int64)
      end

    hsh.to_json
  end

  env.response.content_type = "application/json"
  json
end

Kemal.run
