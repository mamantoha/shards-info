require "kemal"
require "kilt/slang"
require "cache"
require "crest"
require "emoji"

require "./github"

RECENTLY_CACHE = Cache::RedisStore(String, String).new(expires_in: 30.minutes)
POPULAR_CACHE = Cache::RedisStore(String, String).new(expires_in: 30.minutes)

get "/" do
  recently_repos = RECENTLY_CACHE.fetch("repos") do
    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])
    github_client.recently_updated.to_json
  end

  popular_repos = POPULAR_CACHE.fetch("repos") do
    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])
    github_client.popular.to_json
  end

  recently_repos = Github::Repos.from_json(recently_repos)
  popular_repos = Github::Repos.from_json(popular_repos)

  render "src/views/index.slang", "src/views/layouts/layout.slang"
end

Kemal.run
