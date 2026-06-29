require "lustra"
require "../src/db/migrations/**"
require "../src/models/concerns/**"
require "../src/models/**"

def initdb
  pg.exec("DROP DATABASE IF EXISTS shards_info_test;")
  pg.exec("CREATE DATABASE shards_info_test;")

  Lustra::SQL.init(database_url)

  Lustra::Migration::Manager.instance.apply_all

  create_user_with_repository
end

def create_user_with_repository
  user = User.create({
    provider:    "github",
    provider_id: "1",
    login:       "crystal-lang",
    kind:        "user",
    ignore:      false,
    synced_at:   Time.local,
  })

  repository = Repository.create({
    user_id:          user.id,
    provider:         "github",
    provider_id:      "1",
    name:             "crystal",
    default_branch:   "master",
    shard_yml:        "name: shards\nversion: 0.1.0\ndescription: short description",
    stars_count:      1,
    forks_count:      1,
    archived:         false,
    ignore:           false,
    fork:             false,
    last_activity_at: Time.local,
    synced_at:        Time.local,
  })

  shard_tag = Tag.create({name: "shard"})
  cli_tag = Tag.create({name: "cli"})

  RepositoryTag.create({repository_id: repository.id, tag_id: shard_tag.id})
  RepositoryTag.create({repository_id: repository.id, tag_id: cli_tag.id})

  dependent_user = User.create({
    provider:    "github",
    provider_id: "2",
    login:       "mamantoha",
    kind:        "user",
    ignore:      false,
    synced_at:   Time.local,
  })

  dependent_repository = Repository.create({
    user_id:          dependent_user.id,
    provider:         "github",
    provider_id:      "2",
    name:             "crest",
    default_branch:   "master",
    shard_yml:        "name: crest\nversion: 0.1.0\ndependencies:\n  crystal:\n    github: crystal-lang/crystal",
    stars_count:      1,
    forks_count:      1,
    archived:         false,
    ignore:           false,
    fork:             false,
    last_activity_at: Time.local,
    synced_at:        Time.local,
  })

  Relationship.create({
    master_id:     dependent_repository.id,
    dependency_id: repository.id,
    development:   false,
  })
end

def database_url
  ENV["DATABASE_URL"]? || "postgres://postgres:postgres@localhost/shards_info_test"
end

def postgres_user
  ENV["POSTGRES_USER"]? || "postgres"
end

def postgres_password
  ENV["POSTGRES_PASSWORD"]? || "postgres"
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
