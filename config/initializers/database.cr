require "clear"
require "../../src/models/**"
require "../../src/db/seeds"
require "../../src/db/migrations/**"

Clear::SQL.init(ENV["DATABASE_URL"], connection_pool_size: 5)

log_file =
  case ENV["KEMAL_ENV"]
  when "production"
    File.new("#{__DIR__}/../../log/clear.log", "a+")
  else
    STDOUT
  end

Log.builder.bind "clear.*", :debug, Log::IOBackend.new(log_file)
