# Stores all the configuration options for a application.
# It's a singleton and you can access it like.
#
# ```
# Config.config
# ```
class Config
  INSTANCE = Config.new

  @@postgres_version : String?
  @@redis_version : String?

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

  def self.postgres_version : String
    @@postgres_version ||= begin
      version = DB.connect(ENV["DATABASE_URL"]) do |conn|
        conn.version
      end

      "#{version[:major]}.#{version[:minor]}.#{version[:patch]}"
    end
  end

  def self.redis_version : String
    @@redis_version ||= begin
      redis = Redis::Client.new(URI.parse(ENV.fetch("REDIS_URL", "redis:///")))
      info = redis.info

      server_name = info["server_name"]?
      version = server_name == "valkey" ? info["valkey_version"]? : info["redis_version"]?

      "#{server_name}/#{version}"
    end
  end
end
