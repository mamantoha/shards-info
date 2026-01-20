require "../../src/lib/forgejo"

log_file =
  case ENV["KEMAL_ENV"]
  when "production"
    File.new("#{__DIR__}/../../log/codeberg.log", "a+")
  else
    STDOUT
  end

Forgejo.logger = Forgejo::Logger.new(log_file)
