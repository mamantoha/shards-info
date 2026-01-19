class FetchUserJob < MosquitoQueuedJobWithErrorHandler
  param user_id : Int64

  def perform
    if user = User.find(user_id)
      case user.provider
      when "github"
        GithubHelpers.resync_user user
      when "gitlab"
        GitlabHelpers.resync_user user
      end
    end
  end
end
