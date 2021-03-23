require "clear"
require "../config/config"

def initdb
  pg.exec("DROP DATABASE IF EXISTS shards_info_test;")
  pg.exec("CREATE DATABASE shards_info_test;")

  Clear::SQL.init(database_url, connection_pool_size: 5)

  Clear::Migration::Manager.instance.apply_all
end

def database_url
  ENV["DATABASE_URL"]? || "postgres://postgres@localhost/shards_info_test"
end

def pg
  DB.open(database_url)
end

Log.setup(:debug)

initdb
