require "kemal"
require "kemal-session"
require "kemal-flash"

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
  config.gc_interval = 2.minutes
end
