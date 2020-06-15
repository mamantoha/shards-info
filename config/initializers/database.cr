require "clear"
require "../../src/models/**"
require "../../src/db/seeds"
require "../../src/db/migrations/**"

Clear::SQL.init(ENV["DATABASE_URL"], connection_pool_size: 5)

Log.setup(:debug)

# log_file =
#   case ENV["KEMAL_ENV"]
#   when "production"
#     File.new("#{__DIR__}/../../log/clear.log", "a+")
#   else
#     STDOUT
#   end
#
# Clear.logger = Logger.new(log_file)
# Clear.logger.level = Logger::DEBUG
