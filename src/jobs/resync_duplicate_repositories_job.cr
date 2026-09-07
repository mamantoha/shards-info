class ResyncDuplicateRepositoriesJob < PeriodicJobWithErrorHandler
  run_every 10.minutes

  def perform
    duplicate_paths = Repository
      .query
      .group_by(:provider)
      .group_by(:user_id)
      .group_by(:name)
      .having("COUNT(*) > 1")
      .limit(10)
      .pluck(provider: String, user_id: Int64, name: String)

    duplicate_paths.each do |provider, user_id, name|
      Repository
        .query
        .where(provider: provider, user_id: user_id, name: name)
        .each do |repository|
          FetchRepositoryJob.new(repository.id).enqueue
        end
    end
  end
end
