class Repository
  include Clear::Model

  primary_key

  column provider : String
  column provider_id : Int32
  column name : String
  column description : String?
  column shard_yml : String?
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

  has_many relationships : Relationship, foreign_key: "master_id"
  has_many dependencies : Repository, through: Relationship, foreign_key: "dependency_id", own_key: "master_id"
  has_many dependents : Repository, through: Relationship, foreign_key: "master_id", own_key: "dependency_id"

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

  def provider_url
    case provider
    when "gitlab"
      "https://gitlab.com/#{user.login}/#{name}"
    when "github"
      "https://github.com/#{user.login}/#{name}"
    else
      ""
    end
  end

  def provider_icon
    case provider
    when "gitlab"
      "fab fa-gitlab"
    when "github"
      "fab fa-github"
    else
      ""
    end
  end
end
