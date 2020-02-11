# Stores all the configuration options for a application.
# It's a singleton and you can access it like.
#
# ```
# Config.config
# ```
class Config
  INSTANCE = Config.new

  property page_title
  property page_description
  property open_graph
  property query
  property current_page

  def initialize
    @page_title = "shards.info"
    @page_description = "View of all repositories on Github and Gitlab that have Crystal code in them"
    @open_graph = OpenGraph.new
    @query = ""
    @current_page = "home"
  end

  def self.config
    Config::INSTANCE
  end

  def self.date
    {{ `date -R`.stringify.chomp }}
  end
end

struct OpenGraph
  property site_name, title, type, description, image, url

  def initialize(
    @site_name = "shards.info",
    @title = "shards.info",
    @type = "object",
    @description = "View of all repositories on Github and Gitlab that have Crystal code in them",
    @image = "https://shards.info/images/logo.png",
    @url = "https://shards.info"
  )
  end
end
