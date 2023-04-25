require "../lib/linguist/language"

module Helpers
  extend self

  def sync_repository_by_url(url : String) : Repository?
    uri = URI.parse(url)

    if match = uri.path.match(/^\/([\w|\-|_|\.]*)\/([\w|\-|_|\.]*)$/)
      user_name = match[1]
      repository_name = match[2]

      case uri.host
      when "github.com"
        github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

        if github_repo = github_client.repo(user_name, repository_name)
          GithubHelpers.sync_github_repo(github_repo)
        end
      when "gitlab.com"
        gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

        if gitlab_project = gitlab_client.project(user_name, repository_name)
          GitlabHelpers.sync_project(gitlab_project)
        end
      end
    end
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

  def create_relationships(master_repository : Repository, spec_dependencies : Array(ShardsSpec::Dependency), development : Bool)
    spec_dependencies.each do |spec_dependency|
      branch = spec_dependency.refs
      version = spec_dependency.version

      if provider_name = (spec_dependency.keys & ["github", "gitlab"]).first?
        if repository_path = spec_dependency[provider_name]
          user_name, repository_name = repository_path.split("/")

          dependency_repository = Repository.find_repository(user_name, repository_name, provider_name)

          unless dependency_repository
            case provider_name
            when "github"
              github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

              begin
                if github_repo = github_client.repo(user_name, repository_name)
                  dependency_repository = GithubHelpers.sync_github_repo(github_repo)
                end
              rescue Crest::NotFound
                next
              end
            when "gitlab"
              gitlab_client = Gitlab::API.new(ENV["GITLAB_ACCESS_TOKEN"])

              begin
                if gitlab_project = gitlab_client.project(user_name, repository_name)
                  dependency_repository = GitlabHelpers.sync_project(gitlab_project)
                end
              rescue Crest::NotFound
                next
              end
            end
          end

          next unless dependency_repository

          unless Relationship.query.find({
                   master_id:     master_repository.id,
                   dependency_id: dependency_repository.id,
                   development:   development,
                 })
            Relationship.create!({
              master_id:     master_repository.id,
              dependency_id: dependency_repository.id,
              development:   development,
              branch:        branch,
              version:       version,
            })
          end
        end
      end
    end
  end

  def remove_outdated_relationships(repository : Repository, spec_dependencies : Array(ShardsSpec::Dependency), development : Bool)
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
    ShardsSpec::Spec.from_yaml(s)
  rescue
    nil
  end

  def to_markdown(repository : Repository, readme_content : String) : String
    options = Cmark::Option.flags(Unsafe, Nobreaks, ValidateUTF8)
    extensions = Cmark::Extension.flags(Table, Strikethrough, Autolink, Tagfilter, Tasklist)

    node = Cmark.parse_gfm(readme_content, options)
    renderer = ReadmeRenderer.new(options, extensions, repository: repository)

    Emoji.emojize(renderer.render(node))
  end

  def update_languages_color
    Language.query.each do |language|
      if linguist_language = Linguist::Language.find_by_name(language.name)
        language.color = linguist_language.color
        language.save!
      end
    end
  end
end
