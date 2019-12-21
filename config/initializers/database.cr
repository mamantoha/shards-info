require "jennifer"
require "jennifer/adapter/postgres"

Jennifer::Config.read("config/database.yml", ENV["KEMAL_ENV"]? || "development")
Jennifer::Config.from_uri(ENV["DATABASE_URL"]) if ENV.has_key?("DATABASE_URL")

Jennifer::Config.configure do |conf|
  conf.logger.level = Logger::DEBUG
end
