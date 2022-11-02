require "../lib/github"

class ResyncGithubUsersJob < Mosquito::PeriodicJob
  include ErrorHandler

  run_every 30.minutes

  def perform
    return unless ENV["KEMAL_ENV"] == "production"

    users = User
      .query
      .where({provider: "github"})
      .order_by(synced_at: :asc)
      .limit(100)

    users.each do |user|
      GithubHelpers.resync_user(user)
    rescue
      next
    end
  end
end
