require "clear"
require "../src/db/migrations/**"
require "../src/models/**"

def initdb
  pg.exec("DROP DATABASE IF EXISTS shards_info_test;")
  pg.exec("CREATE DATABASE shards_info_test;")

  Clear::SQL.init(database_url, connection_pool_size: 5)

  Clear::Migration::Manager.instance.apply_all

  create_user_with_repository
end

def create_user_with_repository
  user = User.create({
    provider:    "github",
    provider_id: "1",
    login:       "crystal-lang",
    kind:        "user",
    synced_at:   Time.local,
  })

  Repository.create({
    user_id:          user.id,
    provider:         "github",
    provider_id:      "1",
    name:             "crystal",
    stars_count:      1,
    forks_count:      1,
    archived:         false,
    ignore:           false,
    last_activity_at: Time.local,
    synced_at:        Time.local,
  })
end

def database_url
  ENV["DATABASE_URL"]? || "postgres://postgres:postgres@localhost/shards_info_test"
end

def postgres_user
  ENV["POSTGRES_USER"]? || "postgres"
end

def postgres_password
  ENV["POSTGRES_PASSWORD"]? || ""
end

def postgres_host
  ENV["POSTGRES_HOST"]? || "localhost"
end

def postgres_db
  ENV["POSTGRES_DB"]? || "postgres"
end

def pg
  DB.open("postgres://#{postgres_user}:#{postgres_password}@#{postgres_host}/#{postgres_db}")
end

Log.setup(:debug)

initdb
