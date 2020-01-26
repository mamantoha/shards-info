require "shards/spec"

module GitlabHelpers
  extend self

  def sync_project(gilab_project : Gitlab::Project)
    return if gilab_project.forked_from_project

    owner = gilab_project.namespace
    tags = gilab_project.tag_list

    user = User.query.find_or_create({provider: "gitlab", provider_id: owner.id}) { }
    update_user(user, owner)
    user.save

    repository = Repository.query.find_or_build({provider: "gitlab", provider_id: gilab_project.id}) { }
    repository.user = user
    update_repository(repository, gilab_project)
    repository.save

    repository.tags = tags

    set_repository_shard_yml(repository)
    set_repository_readme(repository)
    sync_releases(repository)
    Helpers.update_dependecies(repository)
  end

  def update_user(user : User, owner : Gitlab::Namespace)
    user.update({
      login:      owner.path,
      name:       owner.name,
      kind:       owner.kind,
      avatar_url: owner.avatar_url,
      synced_at:  Time.utc,
    })
  end

  def update_repository(repository : Repository, gitlab_project : Gitlab::Project)
    repository.update({
      name:              gitlab_project.path,
      description:       gitlab_project.description,
      last_activity_at:  gitlab_project.last_activity_at,
      stars_count:       gitlab_project.star_count,
      forks_count:       gitlab_project.forks_count,
      open_issues_count: gitlab_project.open_issues_count,
      created_at:        gitlab_project.created_at,
      synced_at:         Time.utc,
    })
  end

  def set_repository_shard_yml(repository : Repository)
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

  def set_repository_readme(repository : Repository)
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

  def sync_releases(repository : Repository)
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
