class FetchRepositoryJob < MosquitoQueuedJobWithErrorHandler
  param repository_id : Int64

  def perform
    if repository = Repository.find(repository_id)
      case repository.provider
      when "github"
        GithubHelpers.resync_repository repository
      when "gitlab"
        GitlabHelpers.resync_repository repository
      end
    end
  end
end
