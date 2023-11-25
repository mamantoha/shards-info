class ResyncRepositoriesJob < PeriodicJobWithErrorHandler
  run_every 10.minutes

  def perform
    repositories =
      Repository
        .query
        .order_by(synced_at: :asc)
        .limit(50)

    repositories.each do |repository|
      FetchRepositoryJob.new(repository.id).enqueue
    end
  end
end
