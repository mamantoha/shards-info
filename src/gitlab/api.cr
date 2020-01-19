require "crest"

module Gitlab
  class Logger < Crest::Logger
    def request(request) : String
      message = ">> | %s | %s" % [request.method, request.url]
      @logger.info(message)
      message
    end

    def response(response) : String
      message = "<< | %s | %s" % [response.status_code, response.url]
      @logger.info(message)
      message
    end
  end

  class API
    property client

    def initialize(@access_token : String)
      @base_url = "https://gitlab.com/api/v4"
    end

    def client
      uri = URI.parse(@base_url)
      http_client = HTTP::Client.new(uri)
      http_client.connect_timeout = 5.seconds
      http_client.read_timeout = 30.seconds

      @client ||= Crest::Resource.new(
        @base_url,
        headers: {
          "Content-Type" => "application/json",
        },
        params: {
          "access_token" => @access_token,
        },
        http_client: http_client,
        logging: true,
        logger: Logger.new
      )
    end

    def make_request(url : String, params = {} of String => String)
      client[url].get(params: params)
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

    def project(id : Int32)
      url = "/projects/#{id}"

      params = {
        "license" => "true",
      }

      response = make_request(url, params)

      Gitlab::Project.from_json(response.body)
    end

    def project_releases(project_id : Int32)
      url = "/projects/#{project_id}/releases"

      response = make_request(url)

      Gitlab::Releases.from_json(response.body)
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
      url = "/projects/#{project_id}/repository/files/#{file_path}"
      params = {
        "ref" => "master",
      }

      response = make_request(url, params)

      Gitlab::RepositoryFile.from_json(response.body)
    end
  end
end
