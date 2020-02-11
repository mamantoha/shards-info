class RepositoryTag
  include Clear::Model

  primary_key

  belongs_to repository : Repository
  belongs_to tag : Tag
end
