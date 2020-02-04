require "../lib/gitlab"

class ResyncGitlabUsersJob < Mosquito::PeriodicJob
  run_every 12.hours

  def perform
    return unless ENV["KEMAL_ENV"] == "production"

    users = User
      .query
      .where({provider: "gitlab"})
      .order_by(synced_at: :asc)
      .limit(100)

    users.each do |user|
      begin
        GitlabHelpers.sync_user(user)
      rescue
        next
      end
    end
  end
end
