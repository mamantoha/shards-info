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
          rescue
            # Only the first 1000 search results are available
            # otherwise Github returns 422 error
            #
            # TODO: in case we notice that more than 1000 results are returned for a period,
            # we would have to narrow the period even more.
            break
          end
        end
      end

      # repos.uniq.size # 5054 items by 2019-12-26

      repos.uniq
    end
  end
end

github_client = Github::API.new(ENV["GITHUB_USER"], ENV["GITHUB_KEY"])

repos = github_client.all

repos.each do |repo|
  # TODO
end
