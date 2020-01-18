require "../../config/config"
require "../github"

module Github
  class API
    def all
      # The Github Search API returns up to 1000 results per query (including pagination), as documented here:
      # https://developer.github.com/v3/search/#about-the-search-api
      #
      # However, there's a neat trick we could use to fetch more than 1000 results when executing a repository search.
      # We will split up our search into segments, by the date when the repositories were created.
      #
      # For example, we could first search for repositories that were created in October 2019, then September 2019, and so on.
      # Because we would be restricting search to a narrow period, we will probably get less than 1000 results,
      # and would therefore be able to get all of them.
      # In case we notice that more than 1000 results are returned for a period, we would have to narrow the period even more,
      # so that we can collect all results.
      #
      repos = [] of Github::Repo

      word = ""
      language = "Crystal"
      per_page = 100

      # Hardcoded periods with less then 1000 results
      periods = [
        Time.utc(1970, 1, 1)..Time.utc(2016, 1, 1),
        Time.utc(2016, 1, 1)..Time.utc(2017, 1, 1),
        Time.utc(2017, 1, 1)..Time.utc(2017, 6, 1),
        Time.utc(2017, 6, 1)..Time.utc(2018, 1, 1),
        Time.utc(2018, 1, 1)..Time.utc(2018, 6, 1),
        Time.utc(2018, 6, 1)..Time.utc(2019, 1, 1),
        Time.utc(2019, 1, 1)..Time.utc(2019, 6, 1),
        Time.utc(2019, 6, 1)..Time.utc(2020, 1, 1),
        Time.utc(2020, 1, 1)..Time.utc,
      ]

      periods = periods.reduce([] of String) do |acc, range|
        acc << "#{range.begin.to_rfc3339}..#{range.end.to_rfc3339}"
      end

      periods.each do |period|
        page = 1

        loop do
          begin
            url = "/search/repositories?q=#{word}+language:#{language}+created:#{period}&per_page=#{per_page}&page=#{page}"

            response = make_request(url)
            github_repos = Github::Repos.from_json(response.body)

            break if github_repos.items.empty?

            repos = repos + github_repos.items
            page += 1
          rescue ex
            # Only the first 1000 search results are available
            # otherwise Github returns 422 error
            #
            # TODO: in case we notice that more than 1000 results are returned for a period,
            # we would have to narrow the period even more.
            puts "[ERROR]"
            puts ex.message
            break
          end
        end
      end

      repos.uniq
    end
  end
end

github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

print "Getting repositories from Github..."
repos = github_client.all
puts "OK!"

repos.each do |repo|
  tags = repo.tags
  github_user = repo.user

  user = User.query.find_or_create({provider: "github", provider_id: github_user.id}) do |u|
    u.login = github_user.login
    u.name = github_user.name
    u.kind = github_user.kind
    u.avatar_url = github_user.avatar_url
    u.created_at = github_user.created_at
    u.synced_at = Time.utc
  end

  repository = Repository.query.find_or_create({provider: "github", provider_id: repo.id}) do |r|
    r.user = user
    r.name = repo.name
    r.description = repo.description
    r.last_activity_at = repo.updated_at
    r.stars_count = repo.watchers_count
    r.forks_count = repo.forks_count
    r.open_issues_count = repo.open_issues_count
    r.created_at = repo.created_at
    r.synced_at = Time.utc
  end

  repository.tags = tags
end
