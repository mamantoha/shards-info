require "crest"
require "retriable"

module Gitlab
  class Logger < Crest::Logger
    def request(request) : Nil
      message = ">> | %s | %s" % [request.method, request.url]
      @logger.info { message }
      message
    end

    def response(response) : Nil
      message = "<< | %s | %s" % [response.status_code, response.url]
      @logger.info { message }
      message
    end
  end

  class API
    property client
    property logging

    def initialize(@access_token : String, @logging = true)
      @base_url = "https://gitlab.com/api/v4"
    end

    def client
      @client ||= begin
        uri = URI.parse(@base_url)
        http_client = HTTP::Client.new(uri)
        http_client.connect_timeout = 5.seconds
        http_client.read_timeout = 30.seconds

        Crest::Resource.new(
          @base_url,
          headers: {
            "Content-Type" => "application/json",
          },
          params: {
            "access_token" => @access_token,
          },
          http_client: http_client,
          logging: @logging,
          logger: Gitlab.logger
        )
      end
    end

    def make_request(url : String, params = {} of String => String)
      Retriable.retry(on: {Crest::InternalServerError, Crest::ServiceUnavailable, Crest::BadGateway}) do
        client[url].get(params: params)
      end
    ensure
      client.http_client.close
    end

    # Recursive get Crystal projects
    def projects(page = 1, items = [] of Gitlab::Project, per_page = 100) : Gitlab::Projects
      url = "/projects"
      params = {
        "with_programming_language" => "Crystal",
        "order_by"                  => "updated_at",
        "visibility"                => "public",
        "page"                      => page,
        "per_page"                  => per_page,
      }

      response = make_request(url, params)
      items += Gitlab::Projects.from_json(response.body)

      next_page = response.headers["X-Next-Page"]?

      if next_page && !next_page.as(String).empty?
        projects(next_page.as(String).to_i, items, per_page)
      else
        items
      end
    end

    def recently_updated(per_page = 10)
      url = "/projects"

      params = {
        "with_programming_language" => "Crystal",
        "order_by"                  => "last_activity_at",
        "visibility"                => "public",
        "per_page"                  => per_page,
      }

      response = make_request(url, params)

      Gitlab::Projects.from_json(response.body)
    end

    def project(id : Int32)
      url = "/projects/#{id}"

      params = {
        "license" => "true",
      }

      response = make_request(url, params)

      Gitlab::Project.from_json(response.body)
    end

    def project(full_name : String)
      # make sure that the `NAMESPACE/PROJECT_PATH` is URL-encoded
      # For example, `/` is represented by `%2F`
      path = URI.encode_www_form(full_name)
      url = "/projects/#{path}"

      params = {
        "license" => "true",
      }

      response = make_request(url, params)

      Gitlab::Project.from_json(response.body)
    end

    def project(user : String, project : String)
      project("#{user}/#{project}")
    end

    def project_releases(project_id : Int32)
      url = "/projects/#{project_id}/releases"

      response = make_request(url)

      Gitlab::Releases.from_json(response.body)
    end

    def project_languages(project_id : Int32) : Hash(String, Float64)
      url = "/projects/#{project_id}/languages"

      response = make_request(url)

      Hash(String, Float64).from_json(response.body)
    end

    def user(id : Int32)
      url = "/users/#{id}"

      response = make_request(url)

      Gitlab::User.from_json(response.body)
    end

    def group(id : Int32)
      url = "/groups/#{id}"

      response = make_request(url)

      Gitlab::Group.from_json(response.body)
    end

    def get_file(project_id : Int32, file_path : String)
      project = project(project_id)

      url = "/projects/#{project_id}/repository/files/#{file_path}"
      params = {
        "ref" => project.default_branch,
      }

      response = make_request(url, params)

      Gitlab::RepositoryFile.from_json(response.body)
    end
  end
end
