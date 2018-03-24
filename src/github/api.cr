module Github
  class API
    getter client, base_url

    def initialize(user, key)
      @base_url = "https://api.github.com"

      @client = Crest::Resource.new(
        base_url,
        user: user,
        password: key
      )
    end

    def popular
      search_repositories("", "stars", 1, 10)
    end

    def recently_updated
      search_repositories("", "updated", 1, 10)
    end

    def repo_get(owner : String, repo : String)
      url = "/repos/#{owner}/#{repo}"
      response = client[url].get

      Github::Repo.from_json(response.body)
    end

    # https://developer.github.com/v3/search/#search-repositories
    private def search_repositories(word = "", sort = "stars", page = 1, limit = 100, after_date = 1.years.ago)
      date_filter = after_date.to_s("%Y-%m-%d")
      word = word != "" ? "#{word}+" : ""
      pushed = date_filter != "" ? "+pushed:>#{date_filter}" : ""

      url = "/search/repositories?q=#{word}language:crystal#{pushed}&per_page=#{limit}&sort=#{sort}&page=#{page}"
      puts "#{base_url}#{url}"
      response = client[url].get

      Github::Repos.from_json(response.body)
    end
  end
end
