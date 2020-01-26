require "shards/spec"

module GithubHelpers
  extend self

  def sync_repository(github_repo : Github::Repo)
    tags = github_repo.tags
    github_user = github_repo.user

    user = ::User.query.find_or_create({provider: "github", login: github_user.login}) do |u|
      u.provider_id = github_user.id
      u.name = github_user.name
      u.kind = github_user.kind
      u.avatar_url = github_user.avatar_url
      u.synced_at = Time.utc
    end

    repository = Repository.query.find_or_build({provider: "github", provider_id: github_repo.id}) { }
    repository.user = user
    repository.name = github_repo.name
    repository.description = github_repo.description
    repository.last_activity_at = github_repo.updated_at
    repository.stars_count = github_repo.watchers_count
    repository.forks_count = github_repo.forks_count
    repository.open_issues_count = github_repo.open_issues_count
    repository.created_at = github_repo.created_at
    repository.synced_at = Time.utc

    repository.save!

    repository.tags = tags

    set_repository_shard_yml(repository)
    set_repository_readme(repository)
    sync_releases(repository)
    Helpers.update_dependecies(repository)
  end

  def set_repository_shard_yml(repository : Repository)
    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

    response = github_client.repo_content(repository.user.login, repository.name, "shard.yml")
    shard_file = Base64.decode_string(response.content)

    repository.shard_yml = shard_file
    repository.save
    true
  rescue Crest::NotFound
    true
  rescue
    false
  end

  def set_repository_readme(repository : Repository)
    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

    response = github_client.repo_readme(repository.user.login, repository.name)
    readme_file = Base64.decode_string(response.content)

    repository.readme = readme_file
    repository.save!
    true
  rescue Crest::NotFound
    true
  rescue
    false
  end

  def sync_releases(repository : Repository)
    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

    github_releases = github_client.repo_releases(repository.user.login, repository.name)

    create_releases(repository, github_releases)
    remove_outdated_releases(repository, github_releases)
    true
  rescue
    false
  end

  def create_releases(repository : Repository, github_releases : Array(Github::Release))
    github_releases.each do |github_release|
      unless repository.releases.find({tag_name: github_release.tag_name})
        Release.create!({
          repository_id: repository.id,
          provider:      "github",
          provider_id:   github_release.id,
          tag_name:      github_release.tag_name,
          name:          github_release.name,
          body:          github_release.body,
          created_at:    github_release.created_at,
          published_at:  github_release.published_at,
        })
      end
    end
  end

  def remove_outdated_releases(repository : Repository, github_releases : Array(Github::Release))
    releases = repository.releases

    releases.each do |release|
      if github_releases.none? { |github_release| github_release.tag_name == release.tag_name }
        release.delete
      end
    end
  end
end
