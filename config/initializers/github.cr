require "../../src/lib/github"

log_file =
  case ENV["KEMAL_ENV"]
  when "production"
    File.new("log/github.log", "a+")
  else
    STDOUT
  end

Github.logger = Github::Logger.new(log_file)
