# Stores all the configuration options for a application.
# It's a singleton and you can access it like.
#
# ```
# Config.config
# ```
class Config
  INSTANCE = Config.new

  def initialize
  end

  def self.config
    Config::INSTANCE
  end

  def self.date
    {{ `date -R`.stringify.chomp }}
  end

  def self.nodejs_version
    {{ `node -v`.chomp.stringify }}
  end

  def self.postgres_version
    version = DB.connect(ENV["DATABASE_URL"]) do |conn|
      conn.version
    end

    "#{version[:major]}.#{version[:minor]}.#{version[:patch]}"
  end
end
