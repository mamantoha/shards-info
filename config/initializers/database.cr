require "clear"
require "../../src/db/migrations/**"
require "../../src/models/**"
require "../../src/db/seeds"

Clear::SQL.init(ENV["DATABASE_URL"], connection_pool_size: 5)
Clear.logger.level = ::Logger::DEBUG
