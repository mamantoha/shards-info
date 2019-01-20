require "yaml"
require "base64"
require "kemal"
require "kemal-session"
require "kemal-flash"
require "kilt/slang"
require "cache"
require "crest"
require "emoji"
require "humanize_time"
require "simple_markdown"
require "autolink"
require "raven"
require "raven/integrations/kemal"

require "./github"
require "./config"
require "./view_helpers"

Kemal::Session.config do |config|
  config.secret = "my_super_secret"
end

Raven.configure do |config|
  config.async = true
  config.environments = %w(production)
  config.connect_timeout = 5.seconds
  config.read_timeout = 5.seconds
end

Kemal.config.add_handler(Raven::Kemal::ExceptionHandler.new)

CACHE         = Cache::MemoryStore(String, String).new(expires_in: 30.minutes)
GITHUB_CLIENT = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

static_headers do |response, filepath, filestat|
  duration = 1.day.total_seconds.to_i
  response.headers.add "Cache-Control", "public, max-age=#{duration}"
end

before_all do |env|
  GITHUB_CLIENT.exception_handler = Kemal::Exceptions::RouteNotFound.new(env)

  Config.config.open_graph = OpenGraph.new
  Config.config.open_graph.url = "http://shards.info#{env.request.path}"
  Config.config.query = env.request.query_params["query"]?.to_s
end

get "/" do |env|
  recently_repos = CACHE.fetch("recently_repos", expires_in: 5.minutes) do
    GITHUB_CLIENT.recently_updated.to_json
  end

  trending_repos = CACHE.fetch("trending_repos") do
    GITHUB_CLIENT.trending.to_json
  end

  recently_repos = Github::Repos.from_json(recently_repos)
  trending_repos = Github::Repos.from_json(trending_repos)

  Config.config.page_title = "Shards Info"

  render "src/views/index.slang", "src/views/layouts/layout.slang"
end

get "/repos" do |env|
  if env.params.query.[]?("query").nil?
    env.redirect "/"
  else
    query = env.params.query["query"].as(String)

    page = env.params.query["page"]? || ""
    page = page.to_i? || 1

    repos = CACHE.fetch("search_#{query}_#{page}") do
      GITHUB_CLIENT.filter(query, page).to_json
    end

    repos = Github::Repos.from_json(repos)

    paginator = ViewHelpers::GithubPaginator.new(repos, page, "/repos?query=#{query}&page=%{page}").to_s

    Config.config.page_title = "Shards Info: search '#{query}'"

    render "src/views/filter.slang", "src/views/layouts/layout.slang"
  end
end

get "/repos/:owner" do |env|
  owner = env.params.url["owner"]

  repos = CACHE.fetch("#{owner}_repos") do
    GITHUB_CLIENT.user_repos(owner).to_json
  end

  user = CACHE.fetch(owner) do
    GITHUB_CLIENT.user(owner).to_json
  end

  user = Github::User.from_json(user)
  repos = Github::UserRepos.from_json(repos)

  Config.config.page_title = "#{user.login} shards"

  Config.config.open_graph.title = "#{user.login} (#{user.name})"
  Config.config.open_graph.description = "#{user.login} has #{repos.size} shards available."
  Config.config.open_graph.image = "#{user.avatar_url}"
  Config.config.open_graph.type = "profile"

  render "src/views/owner.slang", "src/views/layouts/layout.slang"
end

get "/repos/:owner/:repo" do |env|
  owner = env.params.url["owner"]
  repo_name = env.params.url["repo"]

  repo = CACHE.fetch("repos_#{owner}_#{repo_name}") do
    GITHUB_CLIENT.repo_get("#{owner}/#{repo_name}").to_json
  end

  repo = Github::Repo.from_json(repo)

  dependencies = {} of String => Hash(String, String)
  development_dependencies = {} of String => Hash(String, String)

  shard_content = get_content(owner, repo_name, "shard.yml")
  shard_content = Github::Content.from_json(shard_content) rescue nil

  unless show_repository?(shard_content, repo.full_name)
    env.flash["notice"] = "Repository <a href='#{repo.html_url}'>#{repo.full_name}</a> does not have a <strong>shard.yml</strong> file"

    env.redirect back(env)
    next
  end

  if shard_content
    shard_file = decode_github_content(shard_content.content)

    shard = YAML.parse(shard_file)

    if shard["dependencies"]?
      tmp = shard["dependencies"].as_h?
      dependencies = tmp if tmp
    end

    if shard["development_dependencies"]?
      tmp = shard["development_dependencies"].as_h?
      development_dependencies = tmp if tmp
    end
  end

  dependent_repos = CACHE.fetch("dependent_repos_#{owner}_#{repo_name}_1") do
    GITHUB_CLIENT.dependent_repos("#{owner}/#{repo_name}").to_json
  end

  dependent_repos = Github::CodeSearches.from_json(dependent_repos)

  readme = get_readme(owner, repo_name)
  readme = readme.empty? ? nil : Github::Readme.from_json(readme)
  if readme && readme.download_url
    readme_html = content_to_markdown(readme)
  end

  changelog = get_content(owner, repo_name, "CHANGELOG.md")
  changelog = changelog.empty? ? nil : Github::Content.from_json(changelog)
  if changelog && changelog.download_url
    changelog_html = content_to_markdown(changelog)
  end

  Config.config.page_title = "#{repo.full_name}: #{repo.description}"

  Config.config.open_graph.title = "#{repo.full_name}"
  Config.config.open_graph.description = "#{repo.description}"
  Config.config.open_graph.image = "#{repo.owner.avatar_url}"

  render "src/views/repo.slang", "src/views/layouts/layout.slang"
end

get "/repos/:owner/:repo/dependents" do |env|
  owner = env.params.url["owner"]
  repo_name = env.params.url["repo"]

  page = env.params.query["page"]? || ""
  page = page.to_i? || 1

  repo = CACHE.fetch("repos_#{owner}_#{repo_name}") do
    GITHUB_CLIENT.repo_get("#{owner}/#{repo_name}").to_json
  end

  repo = Github::Repo.from_json(repo)

  dependent_repos = CACHE.fetch("dependent_repos_#{owner}_#{repo_name}_#{page}") do
    GITHUB_CLIENT.dependent_repos("#{owner}/#{repo_name}", page: page).to_json
  end

  dependent_repos = Github::CodeSearches.from_json(dependent_repos)

  paginator = ViewHelpers::GithubPaginator.new(dependent_repos, page, "/repos/#{repo.full_name}/dependents?page=%{page}").to_s

  raise Kemal::Exceptions::RouteNotFound.new(env) if dependent_repos.items.empty?

  Config.config.page_title = "#{repo.full_name}: dependent shards"

  render "src/views/dependents.slang", "src/views/layouts/layout.slang"
end

def back(env : HTTP::Server::Context) : String
  env.request.headers.fetch("Referer", "/")
end

def link(url : String?) : String | Nil
  return url unless url

  uri = URI.parse(url)
  if !uri.scheme
    url = "//" + url
  end

  url
end

private def show_repository?(shard_content, repo_fullname)
  shard_content || Config.special_repositories.includes?(repo_fullname) ? true : false
end

private def get_readme(owner : String, repo_name : String)
  CACHE.fetch("readme_#{owner}_#{repo_name}") do
    response = GITHUB_CLIENT.repo_readme(owner, repo_name)
    response.to_json
  rescue Crest::NotFound
    ""
  end
end

private def get_content(owner : String, repo_name : String, filename : String)
  CACHE.fetch("content_#{filename}_#{owner}_#{repo_name}") do
    response = GITHUB_CLIENT.repo_content(owner, repo_name, filename)
    response.to_json
  rescue Crest::NotFound
    ""
  end
end

private def content_to_markdown(content : Github::Content)
  string = decode_github_content(content.content)

  SimpleMarkdown.parse(Emoji.emojize(string))
end

private def decode_github_content(content : String) : String
  Base64.decode_string(content)
end

Kemal.run
