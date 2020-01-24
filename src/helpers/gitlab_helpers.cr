require "shards/spec"

module GitlabHelpers
  extend self

  def sync_project(project : Gitlab::Project)
    return if project.forked_from_project

    owner = project.namespace
    tags = project.tag_list

    user = User.query.find_or_create({provider: "gitlab", provider_id: owner.id}) do |u|
      u.login = owner.path
      u.name = owner.name
      u.kind = owner.kind
      u.avatar_url = owner.avatar_url
      u.synced_at = Time.utc
    end

    repository = Repository.query.find_or_build({provider: "gitlab", provider_id: project.id}) { }

    repository.user = user
    repository.name = project.path
    repository.description = project.description
    repository.last_activity_at = project.last_activity_at
    repository.stars_count = project.star_count
    repository.forks_count = project.forks_count
    repository.open_issues_count = project.open_issues_count
    repository.created_at = project.created_at
    repository.synced_at = Time.utc

    repository.save!

    repository.tags = tags

    set_repository_shard_yml(repository)
    set_repository_readme(repository)
    Helpers.update_dependecies(repository)
  end

  def set_repository_shard_yml(repository : Repository)
    gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

    response = gitlab_client.get_file(repository.provider_id, "shard.yml")
    content = Base64.decode_string(response.content)

    repository.shard_yml = content
    repository.save
  rescue Crest::NotFound
  end

  def set_repository_readme(repository : Repository)
    gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

    response = gitlab_client.get_file(repository.provider_id, "README.md")
    content = Base64.decode_string(response.content)

    repository.readme = content
    repository.save
  rescue Crest::NotFound
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
