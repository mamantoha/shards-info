require "../lib/github"

class ResyncUsersJob < PeriodicJobWithErrorHandler
  run_every 30.minutes

  def perform
    return unless ENV["KEMAL_ENV"] == "production"

    users = User
      .query
      .order_by(synced_at: :asc)
      .limit(100)

    users.each do |user|
      FetchUserJob.new(user.id).enqueue
    end
  end
end
