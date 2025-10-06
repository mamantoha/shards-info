require "lustra"
require "../../src/models/**"
require "../../src/db/seeds"
require "../../src/db/migrations/**"

Lustra::SQL.init(ENV["DATABASE_URL"])
