require "../lib/github"

class SyncRecentGithubJob < Mosquito::PeriodicJob
  run_every 10.minutes

  def perform
    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])
    github_repositories = github_client.recently_updated.items

    github_repositories.each do |github_repository|
      GithubHelpers.sync_github_repository(github_repository)
    end
  end
end
