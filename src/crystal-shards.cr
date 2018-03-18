require "kemal"
require "kilt/slang"
require "cache"

require "./github"

RECENTLY_CACHE = Cache::MemoryStore(String, String).new(expires_in: 30.minutes)

get "/" do
  client = HTTP::Client.new("api.github.com", 443, true)
  client.basic_auth ENV["GITHUB_USER"], ENV["GITHUB_KEY"]
  url = "/search/repositories?q=language=Crystal"
  response = client.get(url)
  repos = Github::Repos.from_json(response.body)

  render "src/views/index.slang", "src/views/layouts/layout.slang"
end

Kemal.run
