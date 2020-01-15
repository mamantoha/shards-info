require "clear"
require "../../src/models/**"
require "../../src/db/seeds"
require "../../src/db/migrations/**"

Clear::SQL.init(ENV["DATABASE_URL"], connection_pool_size: 5)
Clear.logger.level = ::Logger::DEBUG
