ENV["KEMAL_ENV"] ||= "test"
ENV["DATABASE_URL"] ||= "postgres://postgres:postgres@localhost/shards_info_test"

require "./initdb"
require "spec"
require "spec-kemal"
require "spec-kemal/session"
require "../src/web"
