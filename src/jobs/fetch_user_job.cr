require "../lib/github"

class FetchUserJob < Mosquito::QueuedJob
  param user_id : Int64

  def perform
    user = User.find! user_id
    return if user.synced_at < 1.day.ago

    case user.provider
    when "github"
      GithubHelpers.resync_user user
    when "gitlab"
      GitlabHelpers.resync_user user
    end
  end
end
