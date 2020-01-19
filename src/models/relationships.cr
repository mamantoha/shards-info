class Relationship
  include Clear::Model

  primary_key

  column development : Bool?
  column branch : String?
  column version : String?

  belongs_to master : Repository, foreign_key: "master_id"
  belongs_to dependency : Repository, foreign_key: "dependency_id"
end
