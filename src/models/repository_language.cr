class RepositoryLanguage
  include Clear::Model

  primary_key

  belongs_to repository : Repository
  belongs_to language : Language

  column score : Float32
end
