class FetchRepositoryJob < Mosquito::QueuedJob
  param repository_id : Int64

  def perform
    repository = Repository.find! repository_id

    case repository.provider
    when "github"
      GithubHelpers.resync_repository repository
    when "gitlab"
      GitlabHelpers.resync_repository repository
    end
  end
end
