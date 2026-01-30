class FetchRepositoryJob < MosquitoQueuedJobWithErrorHandler
  param repository_id : Int64

  def perform
    if repository = Repository.find(repository_id)
      repository.resync!
    end
  end
end
