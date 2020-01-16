class Repository
  include Clear::Model

  primary_key

  column provider : String
  column provider_id : Int32
  column name : String
  column description : String?
  column last_activity_at : Time
  column stars_count : Int32
  column forks_count : Int32
  column open_issues_count : Int32?
  column synced_at : Time
  column updated_on : Time?

  full_text_searchable "tsv", catalog: "pg_catalog.simple"

  belongs_to user : User
  has_many tags : Tag, through: RepositoryTag

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
    if provider == "gitlab"
      "https://gitlab.com/#{user.login}/#{name}"
    else
      "https://github.com/#{user.login}/#{name}"
    end
  end
end
