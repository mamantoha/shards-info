module Github
  class API
    getter client

    def initialize(user, key)
      @client = Crest::Resource.new(
        "https://api.github.com",
        user: user,
        password: key
      )
    end

    def best_matched_repos
      url = "/search/repositories?q=language=Crystal"
      response = client[url].get

      Github::Repos.from_json(response.body)
    end
  end
end
