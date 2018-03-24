require "kemal"
require "kilt/slang"
require "cache"
require "crest"
require "emoji"
require "humanize_time"

require "./github"

if ENV["HEROKU"]?
  cache = Cache::MemoryStore(String, String).new(expires_in: 30.minutes)
elsif ENV["REDIS"]?
  cache = Cache::RedisStore(String, String).new(expires_in: 30.minutes)
else
  cache = Cache::NullStore(String, String).new(expires_in: 30.minutes)
end

github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

get "/" do
  recently_repos = cache.fetch("recently_repos", expires_in: 5.minutes) do
    github_client.recently_updated.to_json
  end

  popular_repos = cache.fetch("popular_repos") do
    github_client.popular.to_json
  end

  recently_repos = Github::Repos.from_json(recently_repos)
  popular_repos = Github::Repos.from_json(popular_repos)

  render "src/views/index.slang", "src/views/layouts/layout.slang"
end

get "/repos/:owner" do |env|
  owner = env.params.url["owner"]

  render "src/views/owner.slang", "src/views/layouts/layout.slang"
end

get "/repos/:owner/:repo" do |env|
  owner = env.params.url["owner"]
  repo_name = env.params.url["repo"]

  repo = cache.fetch("repos_#{owner}_#{repo_name}") do
    github_client.repo_get(owner, repo_name).to_json
  end

  repo = Github::Repo.from_json(repo)

  render "src/views/repo.slang", "src/views/layouts/layout.slang"
end

Kemal.run
