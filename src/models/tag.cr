class Tag
  include Lustra::Model

  primary_key

  column name : String

  has_many repository_tags : RepositoryTag
  has_many repositories : Repository, through: RepositoryTag
end
