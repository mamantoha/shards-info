require "kemal"
require "kilt/slang"
require "cache"

require "./github"

REPOS_CACHE = Cache::MemoryStore(String, Github::Repos).new(expires_in: 30.minutes)

get "/" do
  repos = REPOS_CACHE.fetch("repos") do
    client = HTTP::Client.new("api.github.com", 443, true)
    client.basic_auth ENV["GITHUB_USER"], ENV["GITHUB_KEY"]
    url = "/search/repositories?q=language=Crystal"
    response = client.get(url)

    Github::Repos.from_json(response.body)
  end

  render "src/views/index.slang", "src/views/layouts/layout.slang"
end

Kemal.run
