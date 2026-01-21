require "shards_spec"

module CodebergHelpers
  extend self

  def codeberg_client
    Forgejo::API.new("https://codeberg.org/api/v1", ENV["CODEBERG_TOKEN"])
  end

  def resync_repository(repository : Repository)
    return unless repository.provider == "codeberg"
  end

  def sync_repo(codeberg_repo : Forgejo::Repository) : Repository?
    return if codeberg_repo.fork? || codeberg_repo.mirror?

    owner = codeberg_repo.owner
    tags = codeberg_repo.topics

    user = User.query.find_or_build(provider: "codeberg", provider_id: owner.id)
    assign_user_attributes(user, owner)
    user.synced_at = Time.utc if user.changed?
    user.ignore = false unless user.persisted?
    user.save!

    repository = Repository.query.find_or_build(provider: "codeberg", provider_id: codeberg_repo.id)
    repository.ignore = false unless repository.persisted?
    repository.user = user
    assign_project_attributes(repository, codeberg_repo)

    return repository unless repository.changed?

    repository.synced_at = Time.utc
    repository.save!

    repository.tags = tags

    sync_repo_shard_yml(repository)
    sync_repo_readme(repository)
    sync_repo_releases(repository)
    sync_repo_languages(repository)

    Helpers.update_dependecies(repository)

    repository
  end

  def assign_user_attributes(user : User, codeberg_owner : Forgejo::User)
    user.set({
      login:      codeberg_owner.login,
      name:       codeberg_owner.full_name,
      avatar_url: codeberg_owner.avatar_url,
      created_at: codeberg_owner.created,
      bio:        codeberg_owner.description,
      website:    codeberg_owner.website,
      location:   codeberg_owner.location,
      email:      codeberg_owner.email,
      kind:       "user",
    })
  end

  def assign_project_attributes(repository : Repository, codeberg_repo : Forgejo::Repository)
    repository.set({
      provider_id:       codeberg_repo.id,
      name:              codeberg_repo.name,
      description:       codeberg_repo.description,
      default_branch:    codeberg_repo.default_branch,
      last_activity_at:  codeberg_repo.updated_at,
      stars_count:       codeberg_repo.stars_count,
      forks_count:       codeberg_repo.forks_count,
      fork:              codeberg_repo.fork?,
      open_issues_count: codeberg_repo.open_issues_count,
      archived:          codeberg_repo.archived?,
      created_at:        codeberg_repo.created_at,
    })
  end

  def sync_repo_shard_yml(repository)
    content = codeberg_client.get_file(repository.user.login, repository.name, "shard.yml")

    repository.shard_yml = content
    repository.save
    true
  rescue Crest::NotFound
    true
  rescue
    false
  end

  def sync_repo_readme(repository : Repository, readme_file : String = "README.md")
    content = codeberg_client.get_file(repository.user.login, repository.name, readme_file)

    repository.readme = content
    repository.save!
    true
  rescue Crest::NotFound
    true
  rescue
    false
  end

  def sync_repo_releases(repository : Repository)
    codeberg_releases = codeberg_client.repo_releases(repository.user.login, repository.name)

    create_releases(repository, codeberg_releases)
    remove_outdated_releases(repository, codeberg_releases)
    true
  rescue Crest::NotFound
    true
  rescue
    false
  end

  def create_releases(repository : Repository, codeberg_releases : Array(Forgejo::Release))
    codeberg_releases.each do |codeberg_release|
      unless repository.releases.find_by({tag_name: codeberg_release.tag_name})
        Release.create!({
          repository_id: repository.id,
          provider:      "codeberg",
          tag_name:      codeberg_release.tag_name,
          name:          codeberg_release.name,
          body:          codeberg_release.body,
          created_at:    codeberg_release.created_at,
          published_at:  codeberg_release.published_at,
        })
      end
    end
  end

  def remove_outdated_releases(repository : Repository, codeberg_releases : Array(Forgejo::Release))
    releases = repository.releases

    releases.each do |release|
      if codeberg_releases.none? { |codeberg_release| codeberg_release.tag_name == release.tag_name }
        release.delete
      end
    end
  end

  def sync_repo_languages(repository : Repository)
    languages = codeberg_client.repo_languages(repository.user.login, repository.name)

    unlink_languages = repository.language_names - languages.keys

    total_bytes = languages.values.sum

    languages.each do |language_name, bytes|
      score = to_percents(bytes, total_bytes)

      language = Language.query.find_or_create(name: language_name)

      repository_language =
        RepositoryLanguage
          .query
          .find_or_build(repository_id: repository.id, language_id: language.id)

      repository_language.score = score
      repository_language.save!
    end

    unlink_languages.each do |language_name|
      if language = Language.find_by({name: language_name})
        repository.languages.unlink(language)
      end
    end
  end

  private def to_percents(x : Int64, total : Int64) : Float64
    ((x / total) * 100).round(2)
  end
end
