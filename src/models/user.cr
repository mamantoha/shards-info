class User
  include Clear::Model

  primary_key

  column provider : String
  column provider_id : Int32
  column login : String
  column name : String?
  column synced_at : Time
  column created_at : Time?
  column kind : String
  column avatar_url : String?
  column bio : String?
  column location : String?
  column company : String?
  column email : String?
  column website : String?

  has_many repositories : Repository

  def decorate
    @delegator ||= UserDelegator.delegate(self)
  end
end
