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

  def self.redis_version
    redis = Redis::Client.new(URI.parse(ENV.fetch("REDIS_URL", "redis:///")))
    info = redis.info

    server_name = info["server_name"]?
    version = server_name == "valkey" ? info["valkey_version"]? : info["redis_version"]?

    "#{server_name}/#{version}"
  end
end
