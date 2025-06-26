require "json"
require "base64"

module Gitlab
  alias Projects = Array(Project)

  class Project
    include JSON::Serializable

    property id : Int32

    property description : String?

    property name : String

    property name_with_namespace : String

    property path : String

    property path_with_namespace : String

    property created_at : Time

    property default_branch : String?

    property tag_list : Array(String)

    property topics : Array(String)

    property ssh_url_to_repo : String

    property http_url_to_repo : String

    property web_url : String

    property readme_url : String?

    property license_url : String?

    property license : License? # only for single project

    property avatar_url : String?

    property star_count : Int32

    property forks_count : Int32?

    property last_activity_at : Time

    property namespace : Namespace

    @[JSON::Field(key: "_links")]
    property links : Links

    property? empty_repo : Bool

    property? archived : Bool

    property visibility : String

    property owner : Owner?

    property open_issues_count : Int32?

    property description_html : String

    property updated_at : String

    property? can_create_merge_request_in : Bool

    property ci_config_path : String?

    property shared_with_groups : Array(JSON::Any?)

    property permissions : Permissions?

    property? mirror : Bool?

    property forked_from_project : ForkedFromProject?

    def fork? : Bool
      forked_from_project ? true : false
    end
  end

  class ForkedFromProject
    include JSON::Serializable

    property id : Int32

    property description : String?

    property name : String

    property name_with_namespace : String

    property path : String

    property path_with_namespace : String

    property created_at : Time

    property default_branch : String?

    property tag_list : Array(String)

    property ssh_url_to_repo : String

    property http_url_to_repo : String

    property web_url : String

    property readme_url : String?

    property avatar_url : String?

    property star_count : Int32

    property forks_count : Int32?

    property last_activity_at : Time

    property namespace : Namespace
  end

  class Namespace
    include JSON::Serializable

    property id : Int32

    property name : String

    property path : String

    property kind : String # "user", "group"

    property full_path : String

    property parent_id : Int32?

    property avatar_url : String?

    property web_url : String
  end

  class Owner
    include JSON::Serializable

    property id : Int32

    property name : String

    property username : String

    property state : String

    property avatar_url : String

    property web_url : String

    def path
      username
    end

    def full_path
      username
    end

    def kind
      "user"
    end
  end

  class License
    include JSON::Serializable

    property key : String

    property name : String

    property nickname : String?

    property html_url : String?

    property source_url : String?
  end

  class Links
    include JSON::Serializable

    @[JSON::Field(key: "self")]
    property links_self : String

    property issues : String?

    property merge_requests : String?

    property repo_branches : String

    property labels : String

    property events : String

    property members : String
  end

  class Permissions
    include JSON::Serializable

    property project_access : Access?

    property group_access : Access?
  end

  class Access
    include JSON::Serializable

    property access_level : Int32

    property notification_level : Int32
  end

  class User
    include JSON::Serializable

    property id : Int32

    property name : String

    property username : String

    property state : String

    property avatar_url : String

    property web_url : String

    property created_at : Time?

    property bio : String

    property location : String

    property public_email : String?

    property linkedin : String

    property twitter : String

    property website_url : String

    property organization : String
  end

  class Group
    include JSON::Serializable

    property id : Int32

    property web_url : String

    property name : String

    property path : String

    property description : String

    property visibility : String

    property? share_with_group_lock : Bool

    property? require_two_factor_authentication : Bool

    property two_factor_grace_period : Int32

    property project_creation_level : String

    property? auto_devops_enabled : Bool?

    property subgroup_creation_level : String

    property? emails_disabled : Bool

    property? lfs_enabled : Bool

    property avatar_url : String?

    property? request_access_enabled : Bool

    property full_name : String

    property full_path : String

    property created_at : Time

    property parent_id : Int32?

    property projects : Array(Project)

    property shared_projects : Array(JSON::Any?)

    property ldap_cn : String?

    property ldap_access : String?

    property shared_runners_minutes_limit : Int32?

    property extra_shared_runners_minutes_limit : Int32?
  end

  alias Releases = Array(Release)

  class Release
    include JSON::Serializable

    property name : String

    property tag_name : String

    property description : String

    property description_html : String

    property created_at : Time

    property released_at : Time

    property commit : Commit

    property? upcoming_release : Bool

    property commit_path : String

    property tag_path : String

    property assets : Assets

    @[JSON::Field(key: "_links")]
    property links : ReleaseLinks
  end

  class Assets
    include JSON::Serializable

    property count : Int32

    property sources : Array(Source)

    property links : Array(JSON::Any?)
  end

  class Source
    include JSON::Serializable

    property format : String

    property url : String
  end

  class Commit
    include JSON::Serializable

    property id : String

    property short_id : String

    property created_at : Time

    property parent_ids : Array(String)

    property title : String

    property message : String

    property author_name : String

    property author_email : String

    property authored_date : String

    property committer_name : String

    property committer_email : String

    property committed_date : String
  end

  class ReleaseLinks
    include JSON::Serializable
  end

  class RepositoryFile
    include JSON::Serializable

    property file_name : String

    property file_path : String

    property size : Int32

    property encoding : String

    property content_sha256 : String

    property ref : String

    property blob_id : String

    property commit_id : String

    property last_commit_id : String

    property content : String

    def raw_content
      if encoding == "base64"
        Base64.decode_string(content)
      else
        raise "unknown encoding `#{encoding}`"
      end
    end
  end
end
