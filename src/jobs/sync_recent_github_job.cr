require "../lib/github"

class SyncRecentGithubJob < Mosquito::PeriodicJob
  run_every 30.minutes

  def perform
    github_repositories = GITHUB_CLIENT.recently_updated.items

    github_repositories.each do |github_repository|
      GithubHelpers.sync_repository(github_repository)
    end
  end
end
