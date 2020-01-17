class RepositoryTag
  include Clear::Model

  belongs_to repository : Repository, primary: true
  belongs_to tag : Tag
end
