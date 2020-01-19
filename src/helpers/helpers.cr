module Helpers
  extend self

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
          if dependency = Repository.query.with_user { |u| u.where(login: user_name) }.find({provider: provider_name, name: repository_name})
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
      repository_path = [dependency.user.login, dependency.name].join('/').downcase

      if spec_dependencies.none? { |dep| dep.fetch(dependency.provider, "").downcase == repository_path }
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
