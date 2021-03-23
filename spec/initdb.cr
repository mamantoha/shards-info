require "clear"
require "../src/db/migrations/**"

def initdb
  pg.exec("DROP DATABASE IF EXISTS shards_info_test;")
  pg.exec("CREATE DATABASE shards_info_test;")

  Clear::SQL.init(database_url, connection_pool_size: 5)

  Clear::Migration::Manager.instance.apply_all
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
