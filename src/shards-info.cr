require "yaml"
require "kemal"
require "kemal-session"
require "kemal-flash"
require "kilt/slang"
require "cache"
require "crest"
require "emoji"
require "humanize_time"
require "markd"

require "./github"
require "./config"

Kemal::Session.config do |config|
  config.secret = "my_super_secret"
end

CACHE         = Cache::MemoryStore(String, String).new(expires_in: 30.minutes)
GITHUB_CLIENT = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

before_all do |env|
  GITHUB_CLIENT.exception_handler = Kemal::Exceptions::RouteNotFound.new(env)
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

  Config.config.page_title = "Crystal Shards"

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

    Config.config.page_title = "Crystal Shards: search '#{query}'"

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

  render "src/views/owner.slang", "src/views/layouts/layout.slang"
end

get "/repos/:owner/:repo" do |env|
  owner = env.params.url["owner"]
  repo_name = env.params.url["repo"]

  repo = CACHE.fetch("repos_#{owner}_#{repo_name}") do
    GITHUB_CLIENT.repo_get("#{owner}/#{repo_name}").to_json
  end

  repo = Github::Repo.from_json(repo)

  shard_content = CACHE.fetch("content_#{owner}_#{repo_name}_shard.yml") do
    response = GITHUB_CLIENT.repo_shard(owner, repo_name)
    response.to_json
  end

  shard_content = Github::Content.from_json(shard_content) rescue nil

  unless shard_content
    env.flash["notice"] = "Repository <a href='#{repo.html_url}' target='_blank'>#{repo.full_name}</a> does not have a <strong>shard.yml</strong> file"

    env.redirect "/"
    next
  end

  dependent_repos = CACHE.fetch("dependent_repos_#{owner}_#{repo_name}") do
    GITHUB_CLIENT.dependent_repos("#{owner}/#{repo_name}").to_json
  end

  dependent_repos = Github::CodeSearches.from_json(dependent_repos)

  dependencies = {} of String => Hash(String, String)
  development_dependencies = {} of String => Hash(String, String)

  if shard_content && shard_content.name == "shard.yml" && shard_content.download_url
    shard_file = Crest.get(shard_content.download_url.not_nil!).body
    shard = YAML.parse(shard_file)

    if shard["dependencies"]?
      dependencies = shard["dependencies"]
    end

    if shard["development_dependencies"]?
      development_dependencies = shard["development_dependencies"]
    end
  end

  readme = CACHE.fetch("readme_#{owner}_#{repo_name}") do
    response = GITHUB_CLIENT.repo_readme(owner, repo_name)
    response.to_json
  rescue Crest::RequestFailed
    ""
  end

  readme = readme.empty? ? nil : Github::Readme.from_json(readme)

  if readme && readme.download_url
    readme_file = Crest.get(readme.download_url.not_nil!).body
    readme_html = Markd.to_html(readme_file)
  end

  Config.config.page_title = "#{repo.full_name}: #{repo.description}"

  render "src/views/repo.slang", "src/views/layouts/layout.slang"
end

def link(url : String?) : String | Nil
  return url unless url

  uri = URI.parse(url)
  if !uri.scheme
    url = "//" + url
  end

  url
end

Kemal.run
