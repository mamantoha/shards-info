class Release
  include Lustra::Model

  primary_key

  column tag_name : String
  column provider : String
  column provider_id : Int32?
  column name : String?
  column body : String?
  column created_at : Time
  column published_at : Time?

  belongs_to repository : Repository

  scope(:published) { where { published_at != nil } }
end
