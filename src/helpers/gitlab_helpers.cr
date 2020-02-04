require "shards/spec"

module GitlabHelpers
  extend self

  def resync_repository(repository : Repository)
    return unless repository.provider == "gitlab"

    gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

    gitlab_project = gitlab_client.project(repository.provider_id)

    owner = gilab_project.owner || gilab_project.namespace
    tags = gilab_project.tag_list

    user = User.query.find_or_build({provider: "gitlab", provider_id: owner.id}) { }
    assign_project_owner_attributes(user, owner)

    if user.changed?
      user.synced_at = Time.utc
      user.save
    end

    repository.user = user
    assign_project_attributes(repository, gilab_project)
    repository.synced_at = Time.utc
    repository.save

    repository.tags = tags

    Helpers.update_dependecies(repository)
  rescue Crest::NotFound
    repository.delete
  end

  def resync_user(user : User)
    case user.kind
    when "user"
      sync_user_with_kind_user(user)
    when "group"
      sync_user_with_kind_group(user)
    end
  end

  def sync_project(gilab_project : Gitlab::Project)
    return if gilab_project.forked_from_project || gilab_project.mirror

    owner = gilab_project.owner || gilab_project.namespace
    tags = gilab_project.tag_list

    user = User.query.find_or_build({provider: "gitlab", provider_id: owner.id}) { }
    assign_project_owner_attributes(user, owner)

    if user.changed?
      user.synced_at = Time.utc
      user.save
    end

    repository = Repository.query.find_or_build({provider: "gitlab", provider_id: gilab_project.id}) { }
    repository.user = user
    assign_project_attributes(repository, gilab_project)

    return unless repository.changed?

    repository.synced_at = Time.utc
    repository.save

    repository.tags = tags

    sync_project_shard_yml(repository)
    sync_project_readme(repository)
    sync_project_releases(repository)

    Helpers.update_dependecies(repository)
  end

  def sync_user_with_kind_user(user : User)
    return unless user.provider == "gitlab" && user.kind == "user"

    gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

    gitlab_user = gitlab_client.user(user.provider_id)

    assign_user_attributes(user, gitlab_user)
    user.synced_at = Time.utc
    user.save
  rescue Crest::NotFound
    user.delete
  end

  def sync_user_with_kind_group(user : User)
    return unless user.provider == "gitlab" && user.kind == "group"

    gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

    gitlab_group = gitlab_client.group(user.provider_id)

    assign_group_attributes(user, gitlab_group)
    user.synced_at = Time.utc
    user.save
  rescue Crest::NotFound
    user.delete
  end

  def assign_user_attributes(user : User, gitlab_user : Gitlab::User)
    user.set({
      login:      gitlab_user.username,
      name:       gitlab_user.name,
      avatar_url: gitlab_user.avatar_url,
      created_at: gitlab_user.created_at,
      bio:        gitlab_user.bio,
      location:   gitlab_user.location,
      company:    gitlab_user.organization,
      email:      gitlab_user.public_email,
      website:    gitlab_user.website_url,
    })
  end

  def assign_group_attributes(user : User, gitlab_group : Gitlab::Group)
    user.set({
      login:      gitlab_group.path,
      name:       gitlab_group.name,
      avatar_url: gitlab_group.avatar_url,
      bio:        gitlab_group.description,
      website:    gitlab_group.web_url,
    })
  end

  def assign_project_owner_attributes(user : User, owner : Gitlab::Namespace | Gitlab::Owner)
    user.set({
      login:      owner.path,
      name:       owner.name,
      kind:       owner.kind,
      avatar_url: owner.avatar_url,
    })
  end

  def assign_project_attributes(repository : Repository, gitlab_project : Gitlab::Project)
    repository.set({
      name:              gitlab_project.path,
      description:       gitlab_project.description,
      last_activity_at:  gitlab_project.last_activity_at,
      stars_count:       gitlab_project.star_count,
      forks_count:       gitlab_project.forks_count,
      open_issues_count: gitlab_project.open_issues_count,
      license:           gitlab_project.license.try(&.name),
      created_at:        gitlab_project.created_at,
    })
  end

  def sync_project_shard_yml(repository : Repository)
    gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

    response = gitlab_client.get_file(repository.provider_id, "shard.yml")
    content = Base64.decode_string(response.content)

    repository.shard_yml = content
    repository.save
    true
  rescue Crest::NotFound
    true
  rescue
    false
  end

  def sync_project_readme(repository : Repository)
    gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

    response = gitlab_client.get_file(repository.provider_id, "README.md")
    content = Base64.decode_string(response.content)

    repository.readme = content
    repository.save
    true
  rescue Crest::NotFound
    true
  rescue
    false
  end

  def sync_project_releases(repository : Repository)
    gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])
    gitlab_releases = gitlab_client.project_releases(repository.provider_id)

    create_releases(repository, gitlab_releases)
    remove_outdated_releases(repository, gitlab_releases)
    true
  rescue Crest::NotFound
    true
  rescue
    false
  end

  def create_releases(repository : Repository, gitlab_releases : Array(Gitlab::Release))
    gitlab_releases.each do |gitlab_release|
      unless repository.releases.find({tag_name: gitlab_release.tag_name})
        Release.create!({
          repository_id: repository.id,
          provider:      "gitlab",
          tag_name:      gitlab_release.tag_name,
          name:          gitlab_release.name,
          body:          gitlab_release.description,
          created_at:    gitlab_release.created_at,
          published_at:  gitlab_release.released_at,
        })
      end
    end
  end

  def remove_outdated_releases(repository : Repository, gitlab_releases : Array(Gitlab::Release))
    releases = repository.releases

    releases.each do |release|
      if gitlab_releases.none? { |gitlab_release| gitlab_release.tag_name == release.tag_name }
        release.delete
      end
    end
  end
end
