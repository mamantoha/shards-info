require "shards/spec"
require "yaml"
require "base64"
require "kemal"
require "kemal-session"
require "kemal-flash"
require "kilt/slang"
require "crest"
require "emoji"
require "humanize_time"
require "common_marker"
require "autolink"
require "raven"
require "raven/integrations/kemal"

require "../config/config"
require "./github"
require "./config"
require "./view_helpers"

Kemal::Session.config do |config|
  config.secret = "my_super_secret"
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

before_all do |env|
  GITHUB_CLIENT.exception_handler = Kemal::Exceptions::RouteNotFound.new(env)

  Config.config.open_graph = OpenGraph.new
  Config.config.open_graph.url = "https://shards.info#{env.request.path}"
  Config.config.query = env.request.query_params["query"]?.to_s
end

get "/" do |env|
  trending_repos = Repository.query.with_user.with_tags.where { last_activity_at > 1.week.ago }.order_by(stars_count: :desc).limit(20)
  recently_repos = Repository.query.with_user.with_tags.order_by(last_activity_at: :desc).limit(20)

  Config.config.page_title = "Shards Info"
  Config.config.page_description = "View of all repositories on GitHub that have Crystal code in them"

  render "src/views/index.slang", "src/views/layouts/layout.slang"
end

get "/users" do |env|
  page = env.params.query["page"]? || ""
  page = page.to_i? || 1
  per_page = 30
  offset = (page - 1) * per_page

  users_query = User
    .query
    .join("repositories") { var("repositories", "user_id") == var("users", "id") }
    .select(
      "users.*",
      "SUM(repositories.stars_count) AS stars_count",
      "COUNT(repositories.*) AS repositories_count",
    )
    .group_by("users.id")
    .order_by(stars_count: :desc)

  total_count = users_query.count

  paginator = ViewHelpers::Paginator.new(page, per_page, total_count, "/users?page=%{page}").to_s

  users = users_query.limit(per_page).offset(offset)

  render "src/views/users/index.slang", "src/views/layouts/layout.slang"
end

get "/search" do |env|
  if env.params.query.[]?("query").nil?
    env.redirect "/"
  else
    page = env.params.query["page"]? || ""
    page = page.to_i? || 1
    per_page = 20
    offset = (page - 1) * per_page

    query = env.params.query["query"].as(String)

    repos_query = Repository
      .query
      .with_tags
      .with_user
      .search(query)
      .order_by(stars_count: :desc)

    total_count = repos_query.count

    paginator = ViewHelpers::Paginator.new(page, per_page, total_count, "/search?query=#{query}&page=%{page}").to_s

    repos = repos_query.limit(per_page).offset(offset)

    Config.config.page_title = "Search for '#{query}'"
    Config.config.page_description = "Search Crystal repositories for '#{query}'"

    render "src/views/search/index.slang", "src/views/layouts/layout.slang"
  end
end

get "/:provider/:owner" do |env|
  provider = env.params.url["provider"]
  owner = env.params.url["owner"]

  if user = User.query.with_repositories(&.with_tags).find({provider: provider, login: owner})
    repos = user.repositories.with_user.with_tags.order_by(stars_count: :desc)
    repos_count = repos.count

    Config.config.page_title = "#{user.login} Crystal repositories"
    Config.config.page_description = "#{user.login} has #{repos_count} Crystal repositories"

    Config.config.open_graph.title = "#{user.login} (#{user.name})"
    Config.config.open_graph.description = "#{user.login} has #{repos_count} Crystal repositories"
    Config.config.open_graph.image = "#{user.avatar}"
    Config.config.open_graph.type = "profile"

    render "src/views/users/show.slang", "src/views/layouts/layout.slang"
  else
    # 404
  end
end

get "/:provider/:owner/:repo" do |env|
  provider = env.params.url["provider"]
  owner = env.params.url["owner"]
  repo = env.params.url["repo"]

  if repository = Helpers.find_repository(owner, repo, provider)
    Config.config.page_title = "#{repository.full_name}: #{repository.description_with_emoji}"
    Config.config.page_description = "#{repository.full_name}: #{repository.description_with_emoji}"

    Config.config.open_graph.title = "#{repository.full_name}"
    Config.config.open_graph.description = "#{repository.description_with_emoji}"
    Config.config.open_graph.image = "#{repository.user.avatar_url}"

    readme_html = content_to_markdown(repository.readme)

    render "src/views/repositories/show.slang", "src/views/layouts/layout.slang"
  else
    # 404
  end
end

# def back(env : HTTP::Server::Context) : String
#   env.request.headers.fetch("Referer", "/")
# end

def link(url : String?) : String | Nil
  return url unless url

  uri = URI.parse(url)
  if !uri.scheme
    url = "//" + url
  end

  url
end

private def content_to_markdown(content : String?)
  if string = content
    options = ["unsafe"]
    extensions = ["table", "strikethrough", "autolink", "tagfilter", "tasklist"]

    md = CommonMarker.new(Emoji.emojize(string), options, extensions)
    md.to_html
  else
    ""
  end
end

Kemal.run
