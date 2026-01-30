require "../lib/linguist/language"

module Helpers
  extend self

  REPOSITORIES_SORT_OPTIONS = {
    "stars"          => "Stars",
    "alphabetical"   => "Alphabetical",
    "dependents"     => "Dependents",
    "dependencies"   => "Dependencies",
    "forks"          => "Forks",
    "recent-updates" => "Recent Updates",
    "new"            => "Newly Added",
    "last-synced"    => "Last Synced",
    "new-release"    => "New Release",
  }

  def sync_repository_by_url(url : String) : Repository?
    uri = URI.parse(url)

    if match = uri.path.match(/^\/([\w|\-|_|\.]*)\/([\w|\-|_|\.]*)$/)
      user_name = match[1]
      repository_name = match[2]

      case uri.host
      when "github.com"
        github_client = GithubHelpers.github_client

        if github_repo = github_client.repo(user_name, repository_name)
          GithubHelpers.sync_github_repo(github_repo)
        end
      when "gitlab.com"
        gitlab_client = GitlabHelpers.gitlab_client

        if gitlab_project = gitlab_client.project(user_name, repository_name)
          GitlabHelpers.sync_project(gitlab_project)
        end
      when "codeberg.org"
        codeberg_client = CodebergHelpers.codeberg_client

        if codeberg_repo = codeberg_client.repo(user_name, repository_name)
          CodebergHelpers.sync_repo(codeberg_repo)
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

          unless Relationship.find_by({
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

  # Returns: {expression:, direction:, nulls}
  def repositories_sort_expression_direction(sort : String)
    case sort
    when "alphabetical"
      {"name", :asc, nil}
    when "stars"
      {"stars_count", :desc, nil}
    when "dependents"
      {"(select COUNT(*) from relationships r WHERE r.dependency_id=repositories.id)", :desc, nil}
    when "dependencies"
      {"(select COUNT(*) from relationships r WHERE r.master_id=repositories.id)", :desc, nil}
    when "forks"
      {"(select COUNT(*) from repository_forks rf WHERE rf.parent_id=repositories.id)", :desc, nil}
    when "recent-updates"
      {"last_activity_at", :desc, nil}
    when "last-synced"
      {"synced_at", :desc, nil}
    when "new"
      {"created_at", :desc, nil}
    when "new-release"
      {"(select MAX(r.created_at) from releases r WHERE r.repository_id=repositories.id)", :desc, :nulls_last}
    else
      {"stars_count", :desc, nil}
    end
  end

  def day_of_war : String
    time_zone = TimeZone.new("Kyiv")

    start = time_zone.local(2022, 2, 24, 3, 40)
    now = time_zone.local

    countdown = Countdown.new(start, now)

    span = now - start

    duration = Time::Duration.new(span)

    total_days_str = pluralize(duration.in_days.to_i, "day", "days")

    "#{total_days_str} or #{countdown.to_s(oxford_comma: true)}"
  end

  def pluralize(count : Int32 | Int64, singular : String, plural : String)
    "#{count} #{count == 1 ? singular : plural}"
  end

  def real_ip(request : HTTP::Request) : String
    # Try to get IP from headers set by NGINX
    real_ip = request.headers["X-Forwarded-For"]?
    real_ip = real_ip.split(",").first.strip if real_ip

    # Fallbacks
    real_ip ||= request.headers["X-Real-IP"]?
    real_ip ||= case remote_address = request.remote_address
                when Socket::IPAddress
                  remote_address.address
                else
                  remote_address.to_s
                end
    real_ip
  end
end
