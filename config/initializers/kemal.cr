require "kemal"

log_file =
  case ENV["KEMAL_ENV"]
  when "production"
    File.new("#{__DIR__}/../../log/kemal.log", "a+")
  else
    STDOUT
  end

Kemal.config.logger = Kemal::LogHandler.new(log_file)
