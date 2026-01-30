require "crest"
require "./models"

module Forgejo
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
    getter base_url, token
    property logging

    def initialize(@base_url : String, @token : String, @logging = true)
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
            "Accept"        => "application/json",
            "Content-Type"  => "application/json",
            "User-Agent"    => "request",
            "Authorization" => "token #{@token}",
          },
          http_client: http_client,
          logging: @logging,
          logger: Forgejo.logger,
          handle_errors: true,
        )
      end
    end

    def make_request(url, params = {} of String => String)
      Retriable.retry(on: {
        Crest::GatewayTimeout,
        IO::TimeoutError,
        OpenSSL::SSL::Error,
      }) do
        client[url].get(params: params)
      end
    ensure
      client.http_client.close
    end

    def user(username : String)
      url = "/users/#{username}"

      response = make_request(url)

      Forgejo::User.from_json(response.body)
    end

    def repo(owner : String, repo_name : String)
      url = "/repos/#{owner}/#{repo_name}"

      response = make_request(url)

      Forgejo::Repository.from_json(response.body)
    end

    def repo_releases(owner : String, repo : String)
      url = "/repos/#{owner}/#{repo}/releases"

      response = make_request(url)

      Forgejo::ReleaseList.from_json(response.body)
    end

    # Get languages and number of bytes of code written
    # `=> {"Crystal" => 109927, "HTML" => 36888}`
    def repo_languages(owner : String, repo : String) : Hash(String, Int64)
      url = "/repos/#{owner}/#{repo}/languages"

      response = make_request(url)

      Hash(String, Int64).from_json(response.body)
    end

    def repos_search(
      query : String,
      # Limit search to repositories with keyword as topic
      topic : Bool = false,
      # sort repos by attribute.
      # Supported values are "alpha", "created", "updated", "size", "git_size", "lfs_size", "stars", "forks" and "id".
      # Default is "alpha"
      sort : String = "created",
      # sort order, either "asc" (ascending) or "desc" (descending).
      # Default is "asc", ignored if "sort" is not specified.
      order : String = "asc",
      # page number of results to return (1-based)
      page : Int32 = 1,
      # page size of results
      limit : Int32 = 100,
    )
      url = "/repos/search?q=#{query}&topic=#{topic}&sort=#{sort}&order=#{order}&page=#{page}&limit=#{limit}"

      response = make_request(url)

      # response.headers # => {"Access-Control-Expose-Headers" => "Link, X-Total-Count", "Alt-Svc" => "h3=\":443\"; ma=2592000,h3=\":443\"; ma=2592000", "Cache-Control" => "max-age=0, private, must-revalidate, no-transform", "Content-Type" => "application/json;charset=utf-8", "Date" => "Tue, 20 Jan 2026 12:51:53 GMT", "Link" => "<https://codeberg.org/api/v1/repos/search?limit=2&order=asc&page=2&q=Crystal&sort=created&topic=true>; rel=\"next\",<https://codeberg.org/api/v1/repos/search?limit=2&order=asc&page=16&q=Crystal&sort=created&topic=true>; rel=\"last\"", "Permissions-Policy" => "interest-cohort=()", "Strict-Transport-Security" => "max-age=63072000; includeSubDomains; preload", "Vary" => "Origin", "Via" => "1.1 Caddy", "X-Content-Type-Options" => "nosniff", "X-Frame-Options" => "SAMEORIGIN", "X-Total-Count" => "31", "Transfer-Encoding" => "chunked"}

      Forgejo::SearchResults.from_json(response.body)
    end

    # Get a file from a repository
    # Returns raw file content.
    def get_file(owner : String, repo_name : String, file_path : String, ref : String = "main") : String
      url = "/repos/#{owner}/#{repo_name}/raw/#{file_path}"

      params = {
        "ref" => ref,
      }
      response = make_request(url, params)

      response.body
    end
  end
end
