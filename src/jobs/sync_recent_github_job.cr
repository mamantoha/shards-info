require "../github"

class SyncRecentGithubJob < Mosquito::PeriodicJob
  run_every 5.minutes

  def perform
    repos = GITHUB_CLIENT.recently_updated.items

    repos.each do |github_repo|
      if repository = Repository.query.find({provider: "github", provider_id: github_repo.id})
        if repository.last_activity_at != github_repo.updated_at
          Github::Helpers.sync_repository(github_repo)
        end
      end
    end
  end
end
