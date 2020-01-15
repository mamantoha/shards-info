class Repository
  include Clear::Model

  primary_key

  column provider : String
  column provider_id : Int32
  column name : String
  column description : String?
  column last_activity_at : Time
  column stars_count : Int32
  column forks_count : Int32
  column open_issues_count : Int32?
  column synced_at : Time

  belongs_to user : User
  has_many tags : Tag, through: RepositoryTag
end
