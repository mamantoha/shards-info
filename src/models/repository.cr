class Repository
  include Lustra::Model

  primary_key

  column provider : String
  column provider_id : Int32
  column name : String
  column description : String?
  column default_branch : String
  column shard_yml : String?
  column readme : String?
  column changelog : String?
  column license : String?
  column last_activity_at : Time
  column stars_count : Int32
  column forks_count : Int32
  column open_issues_count : Int32?
  column archived : Bool
  column ignore : Bool = false
  column fork : Bool = false
  column synced_at : Time
  column created_at : Time?
  column updated_on : Time?

  full_text_searchable "tsv", catalog: "pg_catalog.simple"

  belongs_to user : User

  has_many tags : Tag, through: RepositoryTag

  has_many repository_languages : RepositoryLanguage
  has_many languages : Language, through: RepositoryLanguage

  has_many releases : Release

  has_many dependencies : Repository, through: Relationship, foreign_key: "dependency_id", own_key: "master_id"
  has_many dependents : Repository, through: Relationship, foreign_key: "master_id", own_key: "dependency_id"

  has_one upstream_repository : RepositoryFork, foreign_key: "fork_id"
  has_many forks : Repository, through: RepositoryFork, own_key: "parent_id", foreign_key: "fork_id"

  scope(:published) { where({ignore: false}) }

  scope(:without_releases) do
    where(<<-SQL
      NOT (
        EXISTS (SELECT "releases".* FROM "releases" WHERE (releases.repository_id = repositories.id))
      )
      SQL
    )
  end

  # ```
  # repositories = Repository.query.with_counts
  #
  # repositories.each(fetch_columns: true) do |repository|
  #   repository.name
  #   repository.attributes["dependents_count"]
  # end
  # ```
  scope(:with_counts) do
    self
      .select(
        "repositories.*",
        "(select COUNT(*) from relationships r WHERE r.dependency_id=repositories.id) dependents_count",
        "(select COUNT(*) from relationships r WHERE r.master_id=repositories.id) dependencies_count",
        "(select COUNT(*) from repository_forks rf WHERE rf.parent_id=repositories.id) forks_count"
      )
      .group_by("repositories.id")
  end

  def self.find_repository(user_login : String, repository_name : String, provider : String) : Repository?
    Repository
      .query
      .join(:user)
      .find_by do
        (users.login == user_login) &
          (users.provider == provider) &
          (repositories.provider == provider) &
          (repositories.name == repository_name)
      end
  end

  def decorate
    @delegator ||= RepositoryDelegator.delegate(self)
  end

  def touch : Repository
    self.updated_on = Time.local
    save!
    self
  end

  def postinstall_script : String?
    if _shard_yml = shard_yml
      spec = ShardsSpec::Spec.from_yaml(_shard_yml)
      spec.scripts["postinstall"]?
    end
  rescue
    nil
  end

  def tags=(names : Array(String))
    new_tags = names - tag_names
    new_tags.each do |name|
      tag = Tag.query.find_or_create(name: name)
      tags << tag
    end

    unlink_tags = tag_names - names
    unlink_tags.each do |name|
      if tag = Tag.query.find_by({name: name})
        tags.unlink(tag)
      end
    end

    touch unless (new_tags + unlink_tags).empty?
  end

  def tag_names
    tags.map(&.name)
  end

  def language_names
    languages.map(&.name)
  end
end
