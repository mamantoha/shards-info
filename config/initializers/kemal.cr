require "kemal"
require "kemal-session"
require "kemal-session-redis-engine"
require "kemal-flash"
require "kemal-kilt"

Kemal::Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = ENV["KEMAL_SESSION_SECRET"]
  config.engine = Kemal::Session::RedisEngine.new(ENV["SESSION_REDIS_URL"])
  config.timeout = 30.days
end
