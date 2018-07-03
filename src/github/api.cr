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
    getter base_url, user, key
    property exception_handler

    def initialize(@user : String, @key : String)
      @base_url = "https://api.github.com"
      @exception_handler = Exception.new
    end

    def client
      client = Crest::Resource.new(
        base_url,
        headers: {"Accept" => "application/vnd.github.mercy-preview+json"},
        user: user,
        password: key,
        logging: true,
        logger: Logger.new
      )

      client.http_client.compress = false

      client
    end

    def make_request(url, ignore_exception = false)
      response = client[url].get
    rescue ex : Crest::NotFound | Crest::UnprocessableEntity
      if ignore_exception
        raise ex
      else
        raise exception_handler
      end
    end

    def user(username : String)
      url = "/users/#{username}"

      response = make_request(url)

      Github::User.from_json(response.body)
    end

    def trending
      search_repositories("", "stars", 1, 20, after_date: 1.week.ago)
    end

    def recently_updated
      search_repositories("", "updated", 1, 20)
    end

    def filter(query : String, page = 1)
      search_repositories(query, "stars", page, 10)
    end

    def user_repos(owner : String)
      url = "/users/#{owner}/repos?sort=updated"

      response = make_request(url)

      repos = Github::UserRepos.from_json(response.body)
      repos.select { |repo| repo.languages["Crystal"]? && repo.fork == false }
    end

    def repo_get(full_name : String)
      url = "/repos/#{full_name}"

      response = make_request(url)

      Github::Repo.from_json(response.body)
    end

    def repo_releases(full_name : String)
      url = "/repos/#{full_name}/releases"

      response = make_request(url)

      Github::Releases.from_json(response.body)
    end

    def repo_languages(full_name : String)
      url = "/repos/#{full_name}/languages"

      response = make_request(url)

      JSON.parse(response.body)
    end

    def dependent_repos(full_name : String, page = 1, limit = 10)
      query = URI.escape("github: #{full_name}")
      filename = "shard.yml"
      path = "/"
      type = "Code"

      url = "/search/code?q=#{query}+filename:#{filename}+path:#{path}&type=#{type}&page=#{page}&per_page=#{limit}"

      response = make_request(url)

      Github::CodeSearches.from_json(response.body)
    end

    def repo_shard(owner : String, repo : String)
      url = "/repos/#{owner}/#{repo}/contents/shard.yml"

      response = make_request(url, true)

      Github::Content.from_json(response.body)
    rescue Crest::RequestFailed
      nil
    end

    def repo_readme(owner : String, repo : String)
      url = "/repos/#{owner}/#{repo}/readme"

      response = make_request(url, true)

      Github::Readme.from_json(response.body)
    end

    # https://developer.github.com/v3/search/#search-repositories
    private def search_repositories(word = "", sort = "stars", page = 1, limit = 100, after_date = 1.years.ago)
      date_filter = after_date.to_s("%Y-%m-%d")
      pushed = date_filter != "" ? "+pushed:>#{date_filter}" : ""

      word = word != "" ? "#{URI.escape(word)}" : ""

      url = "/search/repositories?q=#{word}+language:crystal#{pushed}&per_page=#{limit}&sort=#{sort}&page=#{page}"

      response = make_request(url)

      Github::Repos.from_json(response.body)
    end
  end
end
