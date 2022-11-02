require "../lib/gitlab"

class ResyncGitlabRepositoriesJob < PeriodicJobWithErrorHandler
  run_every 1.hour

  def perform
    return unless ENV["KEMAL_ENV"] == "production"

    repositories = Repository
      .query
      .where({provider: "gitlab"})
      .order_by(synced_at: :asc)
      .limit(10)

    repositories.each do |repository|
      GitlabHelpers.resync_repository(repository)
    rescue
      next
    end
  end
end
