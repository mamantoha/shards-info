require "../../src/lib/gitlab"

log_file =
  case ENV["KEMAL_ENV"]
  when "production"
    File.new("log/gitlab.log", "a+")
  else
    STDOUT
  end

Gitlab.logger = Gitlab::Logger.new(log_file)
