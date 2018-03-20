require "kemal"
require "kilt/slang"
require "cache"
require "crest"
require "emoji"
require "humanize_time"

require "./github"

if ENV["HEROKU"]?
  recently_cache = Cache::MemoryStore(String, String).new(expires_in: 30.minutes)
  popular_cache = Cache::MemoryStore(String, String).new(expires_in: 30.minutes)
else
  recently_cache = Cache::RedisStore(String, String).new(expires_in: 30.minutes)
  popular_cache = Cache::RedisStore(String, String).new(expires_in: 30.minutes)
end

get "/" do
  recently_repos = recently_cache.fetch("recently_repos", expires_in: 5.minutes) do
    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])
    github_client.recently_updated.to_json
  end

  popular_repos = popular_cache.fetch("popular_repos") do
    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])
    github_client.popular.to_json
  end

  recently_repos = Github::Repos.from_json(recently_repos)
  popular_repos = Github::Repos.from_json(popular_repos)

  render "src/views/index.slang", "src/views/layouts/layout.slang"
end

Kemal.run
