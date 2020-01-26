class Repository
  include Clear::Model

  primary_key

  column provider : String
  column provider_id : Int32
  column name : String
  column description : String?
  column shard_yml : String?
  column readme : String?
  column changelog : String?
  column license : String?
  column last_activity_at : Time
  column stars_count : Int32
  column forks_count : Int32
  column open_issues_count : Int32?
  column synced_at : Time
  column created_at : Time?
  column updated_on : Time?

  full_text_searchable "tsv", catalog: "pg_catalog.simple"

  belongs_to user : User
  has_many tags : Tag, through: RepositoryTag
  has_many releases : Release
  has_many relationships : Relationship, foreign_key: "master_id"
  has_many dependencies : Repository, through: Relationship, foreign_key: "dependency_id", own_key: "master_id"
  has_many dependents : Repository, through: Relationship, foreign_key: "master_id", own_key: "dependency_id"

  scope(:without_releases) {
    where(<<-SQL
      NOT (
        EXISTS (SELECT "releases".* FROM "releases" WHERE (releases.repository_id = repositories.id))
      )
      SQL
    )
  }

  def self.find_repository(user_login : String, repository_name : String, provider : String) : Repository?
    Repository
      .query
      .join("users") { users.id == repositories.user_id }
      .find {
        (users.login == user_login) &
          (users.provider == provider) &
          (repositories.provider == provider) &
          (repositories.name == repository_name)
      }
  end

  def decorate
    @delegator ||= RepositoryDelegator.delegate(self)
  end

  def touch
    self.updated_on = Time.local
    self.save!
    self
  end

  def tags=(names : Array(String))
    new_tags = names - tag_names
    new_tags.each do |name|
      tag = Tag.query.find_or_create({name: name}) { }
      self.tags << tag
    end

    unlink_tags = tag_names - names
    unlink_tags.each do |name|
      if tag = Tag.query.find!({name: name})
        self.tags.unlink(tag)
      end
    end

    touch
  end

  def tag_names
    self.tags.map(&.name)
  end
end
