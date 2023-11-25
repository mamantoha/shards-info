require "../lib/github"

class ResyncRepositoriesJob < PeriodicJobWithErrorHandler
  run_every 10.minutes

  def perform
    return unless ENV["KEMAL_ENV"] == "production"

    repositories =
      Repository
        .query
        .where{(synced_at == nil) | (synced_at > 1.day.ago) }
        .order_by(synced_at: :asc)
        .limit(50)

    repositories.each do |repository|
      FetchRepositoryJob.new(repository.id).enqueue
    end
  end
end
