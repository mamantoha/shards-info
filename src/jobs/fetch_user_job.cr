class FetchUserJob < MosquitoQueuedJobWithErrorHandler
  param user_id : Int64

  def perform
    if user = User.find(user_id)
      user.resync!
    end
  end
end
