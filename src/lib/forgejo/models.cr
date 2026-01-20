require "json"

# https://codeberg.org/api/swagger
module Forgejo
  class Repository
    include JSON::Serializable

    property id : Int32 # Int64

    property owner : User

    property name : String

    property full_name : String

    property description : String

    property default_branch : String

    property language : String

    property url : String

    property website : String

    property topics : Array(String)

    property forks_count : Int32 # Int64

    property open_issues_count : Int32 # Int64

    property release_counter : Int32 # Int64

    property stars_count : Int32 # Int64

    property created_at : Time

    property updated_at : Time

    property? private : Bool

    property? archived : Bool

    property? fork : Bool

    property? mirror : Bool

    property? has_releases : Bool
  end

  class User
    include JSON::Serializable

    property id : Int32 # Int64

    property login : String

    property full_name : String

    property avatar_url : String

    property email : String

    property location : String

    property description : String

    property website : String

    property created : Time
  end

  class SearchResults
    include JSON::Serializable

    property data : Array(Repository)

    property? ok : Bool
  end

  alias ReleaseList = Array(Release)

  class Release
    include JSON::Serializable

    property id : Int32 # Int64

    property tag_name : String

    property name : String

    property body : String

    property author : User

    property url : String

    property created_at : Time

    property published_at : Time

    property? draft : Bool
  end
end
