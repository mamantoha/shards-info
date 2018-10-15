require "json"

module Github
  class Iterable
    include JSON::Serializable

    property total_count : Int32

    property incomplete_results : Bool
  end

  class User
    include JSON::Serializable

    property login : String

    property id : Int32

    property node_id : String

    property avatar_url : String

    property gravatar_id : String

    property url : String

    property html_url : String

    property followers_url : String

    property following_url : String

    property gists_url : String

    property starred_url : String

    property subscriptions_url : String

    property organizations_url : String

    property repos_url : String

    property events_url : String

    property received_events_url : String

    @[JSON::Field(key: "type")]
    property user_type : String

    property site_admin : Bool

    property name : String?

    property company : String?

    property blog : String

    property location : String?

    property email : String?

    property hireable : Bool?

    property bio : String?

    property public_repos : Int32

    property public_gists : Int32

    property followers : Int32

    property following : Int32

    property created_at : Time

    property updated_at : Time
  end

  class Repos < Iterable
    property items : Array(Repo)
  end

  class Repo
    include JSON::Serializable

    property id : Int32

    property node_id : String

    property name : String

    property full_name : String

    @[JSON::Field(key: "private")]
    property repo_private : Bool

    property owner : Owner

    property html_url : String

    property description : String?

    property fork : Bool

    property url : String

    property forks_url : String

    property keys_url : String

    property collaborators_url : String

    property teams_url : String

    property hooks_url : String

    property issue_events_url : String

    property events_url : String

    property assignees_url : String

    property branches_url : String

    property tags_url : String

    property blobs_url : String

    property git_tags_url : String

    property git_refs_url : String

    property trees_url : String

    property statuses_url : String

    property languages_url : String

    property stargazers_url : String

    property contributors_url : String

    property subscribers_url : String

    property subscription_url : String

    property commits_url : String

    property git_commits_url : String

    property comments_url : String

    property issue_comment_url : String

    property contents_url : String

    property compare_url : String

    property merges_url : String

    property archive_url : String

    property downloads_url : String

    property issues_url : String

    property pulls_url : String

    property milestones_url : String

    property notifications_url : String

    property labels_url : String

    property releases_url : String

    property deployments_url : String

    property created_at : Time

    property updated_at : Time

    property pushed_at : Time?

    property git_url : String

    property ssh_url : String

    property clone_url : String

    property svn_url : String

    property homepage : String?

    property size : Int32

    property stargazers_count : Int32

    property watchers_count : Int32

    property language : String?

    property has_issues : Bool

    property has_projects : Bool

    property has_downloads : Bool

    property has_wiki : Bool

    property has_pages : Bool

    property forks_count : Int32

    property mirror_url : String?

    property archived : Bool

    property open_issues_count : Int32

    property license : License?

    property forks : Int32

    property open_issues : Int32

    property watchers : Int32

    property default_branch : String

    property subscribers_count : Int32?

    property topics : Array(String)?

    property score : Float64?

    def license_name
      @license.try do |license|
        if license.name
          license.name
        else
          ""
        end
      end
    end

    def releases
      releases = CACHE.fetch("releases_#{full_name}") do
        GITHUB_CLIENT.repo_releases(full_name).to_json
      end

      Github::Releases.from_json(releases)
    end

    def latest_release
      releases.first?.try do |release|
        return release.tag_name
      end

      ""
    end
  end

  alias UserRepos = Array(Repo)
  alias Forks = Array(Repo)

  class CodeSearches < Iterable
    property items : Array(CodeSearchItem)
  end

  class CodeSearchItem
    include JSON::Serializable

    property name : String

    property path : String

    property sha : String

    property url : String

    property git_url : String

    property html_url : String

    property repository : CodeSearchRepository

    property score : Float64
  end

  class CodeSearchRepository
    include JSON::Serializable

    property id : Int32

    property node_id : String

    property name : String

    property full_name : String

    @[JSON::Field(key: "private")]
    property repository_private : Bool

    property owner : Owner

    property html_url : String

    property description : String?

    property fork : Bool

    property url : String

    property forks_url : String

    property keys_url : String

    property collaborators_url : String

    property teams_url : String

    property hooks_url : String

    property issue_events_url : String

    property events_url : String

    property assignees_url : String

    property branches_url : String

    property tags_url : String

    property blobs_url : String

    property git_tags_url : String

    property git_refs_url : String

    property trees_url : String

    property statuses_url : String

    property languages_url : String

    property stargazers_url : String

    property contributors_url : String

    property subscribers_url : String

    property subscription_url : String

    property commits_url : String

    property git_commits_url : String

    property comments_url : String

    property issue_comment_url : String

    property contents_url : String

    property compare_url : String

    property merges_url : String

    property archive_url : String

    property downloads_url : String

    property issues_url : String

    property pulls_url : String

    property milestones_url : String

    property notifications_url : String

    property labels_url : String

    property releases_url : String

    property deployments_url : String
  end

  class Organization
    include JSON::Serializable

    property login : String

    property id : Int32

    property node_id : String

    property avatar_url : String

    property gravatar_id : String

    property url : String

    property html_url : String

    property followers_url : String

    property following_url : String

    property gists_url : String

    property starred_url : String

    property subscriptions_url : String

    property organizations_url : String

    property repos_url : String

    property events_url : String

    property received_events_url : String

    @[JSON::Field(key: "type")]
    property organization_type : String

    property site_admin : Bool
  end

  class Owner
    include JSON::Serializable

    property login : String

    property id : Int32

    property node_id : String

    property avatar_url : String

    property gravatar_id : String

    property url : String

    property html_url : String

    property followers_url : String

    property following_url : String

    property gists_url : String

    property starred_url : String

    property subscriptions_url : String

    property organizations_url : String

    property repos_url : String

    property events_url : String

    property received_events_url : String

    @[JSON::Field(key: "type")]
    property owner_type : String

    property site_admin : Bool
  end

  class License
    include JSON::Serializable

    property key : String

    property name : String

    property spdx_id : String?

    property url : String?

    property node_id : String
  end

  alias Releases = Array(Release)

  class Release
    include JSON::Serializable

    property url : String

    property assets_url : String

    property upload_url : String

    property html_url : String

    property id : Int32

    property node_id : String

    property tag_name : String

    property target_commitish : String

    property name : String?

    property draft : Bool

    property author : Author

    property prerelease : Bool

    property created_at : Time

    property published_at : Time

    property assets : Array(JSON::Any)

    property tarball_url : String

    property zipball_url : String

    property body : String?
  end

  class Author
    include JSON::Serializable

    property login : String

    property id : Int32

    property node_id : String

    property avatar_url : String

    property gravatar_id : String

    property url : String

    property html_url : String

    property followers_url : String

    property following_url : String

    property gists_url : String

    property starred_url : String

    property subscriptions_url : String

    property organizations_url : String

    property repos_url : String

    property events_url : String

    property received_events_url : String

    @[JSON::Field(key: "type")]
    property author_type : String

    property site_admin : Bool
  end

  class Content
    include JSON::Serializable

    property name : String

    property path : String

    property sha : String

    property size : Int32

    property url : String

    property html_url : String

    property git_url : String

    property download_url : String

    @[JSON::Field(key: "type")]
    property content_type : String

    property content : String

    property encoding : String

    @[JSON::Field(key: "_links")]
    property links : Links
  end

  class Readme
    include JSON::Serializable

    property name : String

    property path : String

    property sha : String

    property size : Int32

    property url : String

    property html_url : String

    property git_url : String

    property download_url : String

    @[JSON::Field(key: "type")]
    property readme_type : String

    property content : String

    property encoding : String

    @[JSON::Field(key: "_links")]
    property links : Links
  end

  class Links
    include JSON::Serializable

    @[JSON::Field(key: "self")]
    property links_self : String

    property git : String

    property html : String
  end
end
