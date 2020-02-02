require "../lib/github"

class ResyncGithubJob < Mosquito::PeriodicJob
  run_every 10.minutes

  def perform
    return unless ENV["KEMAL_ENV"] == "production"

    repositories =
      Repository
        .query
        .where({provider: "github"})
        .order_by(synced_at: :asc)
        .limit(100)

    repositories.each do |repository|
      GithubHelpers.resync_repository(repository)
    end
  end
end
