# Stores all the configuration options for a application.
# It's a singleton and you can access it like.
#
# ```
# Config.config
# ```
class Config
  INSTANCE = Config.new

  property page_title

  def initialize
    @page_title = "Crystal Shards"
  end

  def self.config
    Config::INSTANCE
  end
end
