class ResyncUsersJob < PeriodicJobWithErrorHandler
  run_every 30.minutes

  def perform
    users = User
      .query
      .order_by(synced_at: :asc)
      .limit(100)

    users.each do |user|
      FetchUserJob.new(user.id).enqueue
    end
  end
end
