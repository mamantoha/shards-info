require "shards/spec"

module GithubHelpers
  extend self

  def sync_repository(github_repository : Github::Repo)
    tags = github_repository.tags
    github_user = github_repository.user

    user = User.query.find_or_build({provider: "github", provider_id: github_user.id}) { }
    update_user(user, github_user)
    user.save!

    repository = Repository.query.find_or_build({provider: "github", provider_id: github_repository.id}) { }
    repository.user = user
    update_repository(repository, github_repository)
    repository.save

    repository.tags = tags

    set_repository_shard_yml(repository)
    set_repository_readme(repository)
    sync_releases(repository)
    Helpers.update_dependecies(repository)
  end

  def update_user(user : User, github_user : Github::User)
    user.update({
      login:      github_user.login,
      name:       github_user.name,
      kind:       github_user.kind,
      avatar_url: github_user.avatar_url,
      synced_at:  Time.utc,
    })
  end

  def update_repository(repository : Repository, github_repository : Github::Repo)
    repository.update({
      name:              github_repository.name,
      description:       github_repository.description,
      last_activity_at:  github_repository.last_activity_at,
      stars_count:       github_repository.watchers_count,
      forks_count:       github_repository.forks_count,
      open_issues_count: github_repository.open_issues_count,
      created_at:        github_repository.created_at,
      license:           github_repository.license.try(&.name),
      synced_at:         Time.utc,
    })
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
