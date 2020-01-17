module Github
  module Helpers
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
      repository.synced_at = Time.utc

      repository.save

      repository.tags = tags

      set_shard_yml!(repository)
    end

    def set_shard_yml!(repository : Repository)
      response = GITHUB_CLIENT.repo_content(repository.user.login, repository.name, "shard.yml")
      shard_file = Base64.decode_string(response.content)

      repository.shard_yml = shard_file
      repository.save
    rescue Crest::NotFound
    end
  end
end
