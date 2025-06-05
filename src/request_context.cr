class RequestContext
  property page_title : String = "shards.info"
  property page_description : String = "View of all repositories on Github and Gitlab that have Crystal code in them"
  property search_query : String = ""
  property current_page : String = "home"
  property open_graph : OpenGraph = OpenGraph.new

  def initialize
  end

  def initialize(&)
    yield self
  end

  struct OpenGraph
    property site_name, title, type, description, image, url

    def initialize(
      @site_name = "shards.info",
      @title = "shards.info",
      @type = "object",
      @description = "View of all repositories on Github and Gitlab that have Crystal code in them",
      @image = "https://shards.info/images/logo.png",
      @url = "https://shards.info",
    )
    end
  end
end

macro set_request_context(env, &)
  request_context = {{env}}.get("request_context").as(RequestContext)
  {{yield}}
  {{env}}.set "request_context", request_context
end
