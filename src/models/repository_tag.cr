class RepositoryTag
  include Lustra::Model

  primary_key

  belongs_to repository : Repository
  belongs_to tag : Tag
end
