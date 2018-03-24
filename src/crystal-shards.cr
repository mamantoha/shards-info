require "kemal"
require "kilt/slang"
require "cache"
require "crest"
require "emoji"
require "humanize_time"

require "./github"

CACHE = Cache::MemoryStore(String, String).new(expires_in: 30.minutes)
GITHUB_CLIENT = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

get "/" do
  recently_repos = CACHE.fetch("recently_repos", expires_in: 5.minutes) do
    GITHUB_CLIENT.recently_updated.to_json
  end

  popular_repos = CACHE.fetch("popular_repos") do
    GITHUB_CLIENT.popular.to_json
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

  repo = CACHE.fetch("repos_#{owner}_#{repo_name}") do
    GITHUB_CLIENT.repo_get("#{owner}/#{repo_name}").to_json
  end

  repo = Github::Repo.from_json(repo)

  unless repo.language == "Crystal"
    env.redirect "/"
  end

  render "src/views/repo.slang", "src/views/layouts/layout.slang"
end

Kemal.run
