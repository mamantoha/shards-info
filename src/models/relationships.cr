class Relationship
  include Clear::Model

  column development : Bool?
  column branch : String?
  column version : String?

  belongs_to master : Repository, foreign_key: "master_id", primary: true
  belongs_to dependency : Repository, foreign_key: "dependency_id"
end
