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
    @page_title = "Shards Info"
    @open_graph = OpenGraph.new
  end

  def self.config
    Config::INSTANCE
  end

  # List of Crystal repositories w/o shard.yml
  # which we want to show anyway.
  def self.special_repositories
    [
      "veelenga/awesome-crystal",
      "crystal-lang/crystal",
      "ysbaddaden/prax.cr",
      "hendisantika/List-All-Programming-Telegram-Group",
      "exercism/crystal",
    ]
  end
end

struct OpenGraph
  property site_name, title, type, description, image, url

  def initialize(
    @site_name = "Shards Info",
    @title = "Shards Info",
    @type = "object",
    @description = "View of all repositories on GitHub that have Crystal code in them.",
    @image = "http://shards.info/logo.png",
    @url = "http://shards.info"
  )
  end
end
