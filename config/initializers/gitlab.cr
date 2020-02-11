require "../../src/lib/gitlab"

log_file =
  case ENV["KEMAL_ENV"]
  when "production"
    File.new("#{__DIR__}/../../log/gitlab.log", "a+")
  else
    STDOUT
  end

Gitlab.logger = Gitlab::Logger.new(log_file)
