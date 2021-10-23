require "kemal"
require "kemal-session"
require "kemal-session-redis"
require "kemal-flash"
require "../../src/ext/kemal"

log_file =
  case ENV["KEMAL_ENV"]
  when "production"
    File.new("#{__DIR__}/../../log/kemal.log", "a+")
  else
    STDOUT
  end

Kemal.config.logger = Kemal::LogHandler.new(log_file)

Kemal::Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = ENV["KEMAL_SESSION_SECRET"]
  config.engine = Kemal::Session::RedisEngine.new(host: "localhost", port: 6379)
  config.timeout = 30.day
end
