require "crest"

module Github
  class Logger < Crest::Logger
    def request(request) : Nil
      message = ">> | %s | %s" % [request.method, request.url]
      @logger.info { message }
    end

    def response(response) : Nil
      message = "<< | %s | %s" % [response.status_code, response.url]
      @logger.info { message }
    end
  end

  class API
    getter base_url, user, key
    property logging

    def initialize(@user : String, @key : String, @logging = true)
      @base_url = "https://api.github.com"
    end

    def client
      @client ||= begin
        uri = URI.parse(@base_url)

        http_client = HTTP::Client.new(uri)
        http_client.connect_timeout = 5.seconds
        http_client.read_timeout = 30.seconds
        http_client.compress = false

        Crest::Resource.new(
          base_url,
          headers: {
            "Accept"       => "application/vnd.github.mercy-preview+json",
            "Content-Type" => "application/json",
            "User-Agent"   => "request",
          },
          user: user,
          password: key,
          logging: @logging,
          logger: Github.logger,
          http_client: http_client
        )
      end
    end

    def make_request(url)
      Retriable.retry(on: {
        Crest::GatewayTimeout,
        IO::TimeoutError,
        OpenSSL::SSL::Error,
      }) do
        client[url].get
      end
    ensure
      client.http_client.close
    end

    def user(username : String)
      url = "/users/#{username}"

      response = make_request(url)

      Github::User.from_json(response.body)
    end

    def crystal_users(page = 1)
      url = "/search/users?q=language:crystal&page=#{page}"

      response = make_request(url)

      Github::Search::Users.from_json(response.body)
    end

    def trending
      search_repositories("", sort: "stars", page: 1, limit: 20, after_date: 1.week.ago)
    end

    def recently_updated
      search_repositories("", sort: "updated", page: 1, limit: 20)
    end

    def filter(query : String, page = 1)
      search_repositories(query, sort: "stars", page: page, limit: 10, after_date: nil)
    end

    def user_repos(owner : String)
      url = "/users/#{owner}/repos?sort=updated"

      response = make_request(url)

      repos = Github::UserRepos.from_json(response.body)
      repos.select { |repo| repo.language == "Crystal" }
    end

    def repo(id : Int32)
      url = "/repositories/#{id}"

      response = make_request(url)

      Github::Repo.from_json(response.body)
    end

    def repo(full_name : String)
      url = "/repos/#{full_name}"

      response = make_request(url)

      Github::Repo.from_json(response.body)
    end

    def repo(owner : String, name : String)
      repo("#{owner}/#{name}")
    end

    def repo_releases(full_name : String) : Array(Github::Release)
      url = "/repos/#{full_name}/releases"

      response = make_request(url)

      Github::Releases.from_json(response.body)
    end

    def repo_releases(user_name : String, repository : String)
      repo_releases("#{user_name}/#{repository}")
    end

    def repo_release_by_tag(owner : String, repo : String, tag : String)
      url = "/repos/#{owner}/#{repo}/releases/tags/#{tag}"

      response = make_request(url)

      Github::Release.from_json(response.body)
    end

    # Lists languages for the specified repository.
    # The value shown for each language is the number of bytes of code written in that language.
    def repo_languages(full_name : String) : Hash(String, Int32)
      url = "/repos/#{full_name}/languages"

      response = make_request(url)

      Hash(String, Int32).from_json(response.body)
    end

    # :ditto:
    def repo_languages(user_name : String, repository : String)
      repo_languages("#{user_name}/#{repository}")
    end

    def repo_forks(full_name : String)
      url = "/repos/#{full_name}/forks"

      response = make_request(url)

      Github::Forks.from_json(response.body)
    end

    def dependent_repos(full_name : String, *, page = 1, limit = 10)
      query = URI.encode("github: #{full_name}")
      filename = "shard.yml"
      path = "/"
      type = "Code"

      url = "/search/code?q=#{query}+filename:#{filename}+path:#{path}&type=#{type}&page=#{page}&per_page=#{limit}"

      response = make_request(url)

      Github::Search::Codes.from_json(response.body)
    end

    def repo_readme(owner : String, repo : String)
      url = "/repos/#{owner}/#{repo}/readme"

      response = make_request(url)

      Github::Readme.from_json(response.body)
    end

    def repo_content(owner : String, repo : String, path : String)
      url = "/repos/#{owner}/#{repo}/contents/#{path}"

      response = make_request(url)

      Github::Content.from_json(response.body)
    end

    # https://developer.github.com/v3/search/#search-repositories
    private def search_repositories(
      word : String,
      *,
      sort = "stars",
      page = 1,
      limit = 100,
      after_date = 1.years.ago,
      language = "Crystal",
    )
      pushed = ""

      if after_date
        date_filter = after_date.to_s("%Y-%m-%d")
        pushed = date_filter.empty? ? "" : "+pushed:>#{date_filter}"
      end

      word = word.empty? ? "" : "#{URI.encode_path(word)}"

      url = "/search/repositories?q=#{word}+language:#{language}#{pushed}&per_page=#{limit}&sort=#{sort}&page=#{page}"

      response = make_request(url)

      Github::Repos.from_json(response.body)
    end
  end
end
