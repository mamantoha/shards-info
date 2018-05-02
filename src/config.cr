# Stores all the configuration options for a application.
# It's a singleton and you can access it like.
#
# ```
# Config.config
# ```
class Config
  INSTANCE = Config.new

  property page_title
  property open_graph

  def initialize
    @page_title = "Crystal Shards"
    @open_graph = OpenGraph.new
  end

  def self.config
    Config::INSTANCE
  end
end

struct OpenGraph
  property site_name, title, type, description, image, url

  def initialize(
    @site_name = "Crystal Shards",
    @title = "Crystal Shards",
    @type = "object",
    @description = "View of all repositories on GitHub that have Crystal code in them.",
    @image = "http://shards.info/logo.png",
    @url = "http://shards.info"
  )
  end
end
