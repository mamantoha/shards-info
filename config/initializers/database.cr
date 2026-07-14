require "lustra"
require "../../src/models/concerns/**"
require "../../src/models/**"
require "../../src/db/seeds"
require "../../src/db/migrations/**"

database_url = ENV["DATABASE_URL"]

Lustra::SQL.init(database_url)
