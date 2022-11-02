require "../lib/github"

class ResyncGithubRepositoriesJob < PeriodicJobWithErrorHandler
  run_every 10.minutes

  def perform
    return unless ENV["KEMAL_ENV"] == "production"

    repositories =
      Repository
        .query
        .where({provider: "github"})
        .order_by(synced_at: :asc)
        .limit(50)

    repositories.each do |repository|
      GithubHelpers.resync_repository(repository)
    rescue
      next
    end
  end
end
