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

  def initialize
    @page_title = "Shards Info"
    @page_description = "View of all repositories on GitHub that have Crystal code in them"
    @open_graph = OpenGraph.new
    @query = ""
  end

  def self.config
    Config::INSTANCE
  end

  def self.date
    {{ `date -R`.stringify.chomp }}
  end

  # List of Crystal repositories w/o shard.yml
  # which we want to show anyway.
  # def self.special_repositories
  #   [
  #     "veelenga/awesome-crystal",
  #     "crystal-lang/crystal",
  #     "ysbaddaden/prax.cr",
  #     "hendisantika/List-All-Programming-Telegram-Group",
  #     "exercism/crystal",
  #     "oprypin/crsfml",
  #     "ffwff/lilith",
  #   ]
  # end
end

struct OpenGraph
  property site_name, title, type, description, image, url

  def initialize(
    @site_name = "Shards Info",
    @title = "Shards Info",
    @type = "object",
    @description = "View of all repositories on GitHub that have Crystal code in them",
    @image = "https://shards.info/images/logo.png",
    @url = "https://shards.info"
  )
  end
end
