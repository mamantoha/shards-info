class Tag
  include Clear::Model

  primary_key

  column name : String

  has_many repositories : Repository, through: RepositoryTag
end
