require "shards/spec"

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
      repository.created_at = github_repo.created_at
      repository.synced_at = Time.utc

      repository.save!

      repository.tags = tags

      set_repository_shard_yml(repository)
      set_repository_readme(repository)
      update_dependecies(repository)
    end

    def set_repository_shard_yml(repository : Repository)
      response = GITHUB_CLIENT.repo_content(repository.user.login, repository.name, "shard.yml")
      shard_file = Base64.decode_string(response.content)

      repository.shard_yml = shard_file
      repository.save
    rescue Crest::NotFound
    end

    def set_repository_readme(repository : Repository)
      response = GITHUB_CLIENT.repo_content(repository.user.login, repository.name, "README.md")
      readme_file = Base64.decode_string(response.content)

      repository.readme = readme_file
      repository.save!
    rescue Crest::NotFound
    end

    def update_dependecies(repository : Repository)
      if shard_yml = repository.shard_yml
        if spec = spec_from_yaml(shard_yml)
          create_relationships(repository, spec.dependencies, false)
          create_relationships(repository, spec.development_dependencies, true)

          remove_outdated_relationships(repository, spec.dependencies, false)
          remove_outdated_relationships(repository, spec.development_dependencies, true)
        end
      end
    end

    def create_relationships(repository : Repository, spec_dependencies : Array(Shards::Dependency), development : Bool)
      spec_dependencies.each do |spec_dependency|
        if provider_name = (spec_dependency.keys & ["github", "gitlab"]).first?
          if repository_path = spec_dependency[provider_name]
            user_name, repository_name = repository_path.split("/")
            if dependency = Repository.query.with_user { |u| u.where(name: user_name) }.find { (provider == provider_name) & (name == repository_name) }
              dependencies = repository.dependencies.where { relationships.development == development }

              unless Relationship.query.find({master_id: repository.id, dependency_id: dependency.id, development: development})
                Relationship.create!({
                  master_id:     repository.id,
                  dependency_id: dependency.id,
                  development:   development,
                  branch:        spec_dependency.refs,
                  version:       spec_dependency.version,
                })
              end
            end
          end
        end
      end
    end

    def remove_outdated_relationships(repository : Repository, spec_dependencies : Array(Shards::Dependency), development)
      dependencies = repository.dependencies.where { relationships.development == development }

      dependencies.each do |dependency|
        repository_path = [dependency.user.login, dependency.name].join('/')

        if spec_dependencies.none? { |dep| dep[repository.provider]? == repository_path }
          if relationship = Relationship.query.where({master_id: repository.id, dependency_id: dependency.id, development: development}).first
            relationship.delete
          end
        end
      end
    end

    def spec_from_yaml(s)
      Shards::Spec.from_yaml(s)
    rescue
      nil
    end
  end
end
