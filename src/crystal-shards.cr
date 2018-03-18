require "kemal"
require "kilt/slang"
require "cache"
require "crest"

require "./github"

REPOS_CACHE = Cache::MemoryStore(String, Github::Repos).new(expires_in: 30.minutes)

get "/" do
  repos = REPOS_CACHE.fetch("repos") do
    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])
    github_client.best_matched_repos
  end

  render "src/views/index.slang", "src/views/layouts/layout.slang"
end

Kemal.run
