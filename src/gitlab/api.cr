require "crest"

module Gitlab
  class API
    property client

    def initialize(@access_token : String)
      @base_url = "https://gitlab.com/api/v4"
    end

    def client
      @client ||= Crest::Resource.new(
        @base_url,
        headers: {
          "Content-Type" => "application/json",
        },
        params: {
          "access_token" => @access_token,
        },
        logging: false
      )
    end

    def make_request(url : String, params = {} of String => String)
      client[url].get(params: params)
    end

    def test_projects : Gitlab::Projects
      url = "/projects"
      params = {
        "with_programming_language" => "Crystal",
        "order_by"                  => "updated_at",
        "visibility"                => "public",
        "page"                      => 1,
        "per_page"                  => 20,
      }

      response = make_request(url, params)

      Gitlab::Projects.from_json(response.body)
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
