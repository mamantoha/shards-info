class Language
  include Lustra::Model

  primary_key

  column name : String
  column color : String?

  has_many repositories : Repository, through: RepositoryLanguage
end
