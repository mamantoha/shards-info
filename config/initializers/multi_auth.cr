require "multi_auth"
require "multi_auth/providers/github"

MultiAuth.config("github", ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"])
