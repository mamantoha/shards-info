require "shards_spec"

module GithubHelpers
  extend self

  def resync_repository(repository : Repository)
    return unless repository.provider == "github"

    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

    github_repository = github_client.get_repo(repository.provider_id)

    tags = github_repository.tags
    github_user = github_repository.user

    user = User.query.find_or_build(provider: "github", provider_id: github_user.id)
    assign_repository_user_attributes(user, github_user)
    user.synced_at = Time.utc
    user.ignore = false unless user.persisted?
    user.save!

    repository.user = user
    assign_repository_attributes(repository, github_repository)
    repository.synced_at = Time.utc
    repository.save!

    repository.tags = tags

    sync_repository_shard_yml(repository)
    sync_repository_readme(repository)
    sync_repository_releases(repository)
    sync_repository_languages(repository)

    Helpers.update_dependecies(repository)
  rescue Crest::NotFound
    repository.delete
  end

  def resync_user(user : User)
    return unless user.provider == "github"

    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

    github_user = github_client.user(user.login)

    assign_user_attributes(user, github_user)
    user.synced_at = Time.utc
    user.save
  rescue Crest::NotFound
    user.delete
  end

  def sync_github_repository(github_repository : Github::Repo) : Repository?
    tags = github_repository.tags
    github_user = github_repository.user

    user = User.query.find_or_build(provider: "github", provider_id: github_user.id)
    assign_repository_user_attributes(user, github_user)
    user.synced_at = Time.utc if user.changed?
    user.ignore = false unless user.persisted?
    user.save!

    repository = Repository.query.find_or_build(provider: "github", provider_id: github_repository.id)
    repository.ignore = false unless repository.persisted?
    repository.user = user
    assign_repository_attributes(repository, github_repository)

    return repository unless repository.changed?

    repository.synced_at = Time.utc
    repository.save!

    repository.tags = tags

    sync_repository_shard_yml(repository)
    sync_repository_readme(repository)
    sync_repository_releases(repository)

    Helpers.update_dependecies(repository)

    repository
  end

  def assign_user_attributes(user : User, github_user : Github::User)
    user.set({
      login:      github_user.login,
      name:       github_user.name,
      kind:       github_user.kind,
      avatar_url: github_user.avatar_url,
      bio:        github_user.bio,
      location:   github_user.location,
      company:    github_user.company,
      email:      github_user.email,
      website:    github_user.blog,
    })
  end

  def assign_repository_user_attributes(user : User, github_user : Github::User)
    user.set({
      login:      github_user.login,
      name:       github_user.name,
      kind:       github_user.kind,
      avatar_url: github_user.avatar_url,
    })
  end

  def assign_repository_attributes(repository : Repository, github_repository : Github::Repo)
    repository.set({
      name:              github_repository.name,
      description:       github_repository.description,
      default_branch:    github_repository.default_branch,
      last_activity_at:  github_repository.last_activity_at,
      stars_count:       github_repository.watchers_count,
      forks_count:       github_repository.forks_count,
      open_issues_count: github_repository.open_issues_count,
      archived:          github_repository.archived,
      created_at:        github_repository.created_at,
      license:           github_repository.license.try(&.name),
    })
  end

  def sync_repository_shard_yml(repository : Repository)
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

  def sync_repository_readme(repository : Repository)
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

  def sync_repository_releases(repository : Repository)
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

  def sync_repository_languages(repository : Repository)
    github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

    languages = github_client.repo_languages(repository.user.login, repository.name)

    unlink_languages = repository.language_names - languages.keys

    total_bytes = languages.values.sum

    languages.each do |language_name, number_of_bytes|
      score = to_percents(number_of_bytes, total_bytes)

      language = Language.query.find_or_create(name: language_name)

      repository_language =
        RepositoryLanguage
          .query
          .find_or_build(repository_id: repository.id, language_id: language.id)

      repository_language.score = score
      repository_language.save!
    end

    unlink_languages.each do |language_name|
      if (language = Language.query.find({name: language_name}))
        repository.languages.unlink(language)
      end
    end
  end

  private def to_percents(x : Int32, total : Int32) : Float64
    ((x / total) * 100).round(2)
  end
end
