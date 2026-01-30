class User
  include Lustra::Model
  include HasProvider

  primary_key

  column provider : String
  column provider_id : Int32
  column login : String
  column path : String?
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
  column ignore : Bool = false

  has_many repositories : Repository

  scope(:published) { where({ignore: false}) }

  def decorate
    @delegator ||= UserDelegator.delegate(self)
  end
end
