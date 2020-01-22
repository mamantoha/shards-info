module Helpers
  extend self

  def find_repository(user_login : String, repository_name : String, provider : String) : Repository?
    Repository
      .query
      .join("users") { users.id == repositories.user_id }
      .find {
        (users.login == user_login) &
          (users.provider == provider) &
          (repositories.provider == provider) &
          (repositories.name == repository_name)
      }
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

          if dependency = Helpers.find_repository(user_name, repository_name, provider_name)
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

  def remove_outdated_relationships(repository : Repository, spec_dependencies : Array(Shards::Dependency), development : Bool)
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

  def to_markdown(content : String?)
    if string = content
      options = ["unsafe"]
      extensions = ["table", "strikethrough", "autolink", "tagfilter", "tasklist"]

      md = CommonMarker.new(Emoji.emojize(string), options, extensions)
      md.to_html
    else
      ""
    end
  end
end
