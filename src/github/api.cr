require "crest"

module Github
  class Logger < Crest::Logger
    def request(request)
      @logger.info ">> | %s | %s" % [request.method, request.url]
    end

    def response(response)
      @logger.info "<< | %s | %s" % [response.status_code, response.url]
    end
  end

  class API
    getter client, base_url

    def initialize(user, key)
      @base_url = "https://api.github.com"

      @client = Crest::Resource.new(
        base_url,
        user: user,
        password: key,
        logging: true,
        logger: Logger.new
      )
    end

    def popular
      search_repositories("", "stars", 1, 10)
    end

    def recently_updated
      search_repositories("", "updated", 1, 10)
    end

    def filter(query : String, page = 1)
      search_repositories(query, "stars", page, 10)
    end

    def repo_get(full_name : String)
      url = "/repos/#{full_name}"
      response = client[url].get

      Github::Repo.from_json(response.body)
    end

    def repo_releases(full_name : String)
      url = "/repos/#{full_name}/releases"
      response = client[url].get

      Github::Releases.from_json(response.body)
    end

    def dependent_repos(full_name : String)
      query = URI.escape("github: #{full_name}")
      filename = "shard.yml"
      type = "Code"

      url = "/search/code?q=#{query}+filename:#{filename}&type=#{type}"
      response = client[url].get

      Github::CodeSearches.from_json(response.body)
    end

    # https://developer.github.com/v3/search/#search-repositories
    private def search_repositories(word = "", sort = "stars", page = 1, limit = 100, after_date = 1.years.ago)
      date_filter = after_date.to_s("%Y-%m-%d")
      word = word != "" ? "\"#{URI.escape(word)}+\"" : ""
      pushed = date_filter != "" ? "+pushed:>#{date_filter}" : ""

      url = "/search/repositories?q=#{word}language:crystal#{pushed}&per_page=#{limit}&sort=#{sort}&page=#{page}"
      puts "#{base_url}#{url}"
      response = client[url].get

      Github::Repos.from_json(response.body)
    end
  end
end
