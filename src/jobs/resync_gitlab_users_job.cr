require "../lib/gitlab"

class ResyncGitlabUsersJob < Mosquito::PeriodicJob
  include ErrorHandler

  run_every 1.hours

  def perform
    return unless ENV["KEMAL_ENV"] == "production"

    users = User
      .query
      .where({provider: "gitlab"})
      .order_by(synced_at: :asc)
      .limit(10)

    users.each do |user|
      GitlabHelpers.resync_user(user)
    rescue
      next
    end
  end
end
