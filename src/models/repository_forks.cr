class RepositoryFork
  include Lustra::Model

  primary_key

  belongs_to parent : Repository, foreign_key: "parent_id"
  belongs_to fork : Repository, foreign_key: "fork_id"
end
