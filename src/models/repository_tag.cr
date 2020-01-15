class RepositoryTag
  include Clear::Model

  belongs_to repository : Repository
  belongs_to tag : Tag
end
