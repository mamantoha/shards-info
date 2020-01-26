require "../lib/github"

class SyncRecentGithubJob < Mosquito::PeriodicJob
  run_every 30.minutes

  def perform
    github_repositories = GITHUB_CLIENT.recently_updated.items

    github_repositories.each do |github_repository|
      if repository = Repository.query.find({provider: "github", provider_id: github_repository.id})
        # Update if repository has been changed
        if repository.last_activity_at != github_repository.last_activity_at
          GithubHelpers.sync_repository(github_repository)
        end
      else
        # Create new repository
        GithubHelpers.sync_repository(github_repository)
      end
    end
  end
end
