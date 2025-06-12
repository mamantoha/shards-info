require "clear"
require "../../src/models/**"
require "../../src/db/seeds"
require "../../src/db/migrations/**"

Clear::SQL.init(ENV["DATABASE_URL"])
