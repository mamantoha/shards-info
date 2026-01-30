class SyncRecentGithubJob < PeriodicJobWithErrorHandler
  run_every 10.minutes

  def perform
    github_client = GithubHelpers.github_client
    github_repos = github_client.recently_updated.items

    github_repos.each do |github_repo|
      next if github_repo.private?

      GithubHelpers.sync_github_repo(github_repo)
    end
  end
end
