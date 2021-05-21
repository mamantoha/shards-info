require "multi_auth"

MultiAuth.config("github", ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"])
