require "dotenv"
require "mosquito"
require "shards/spec"

Dotenv.load

require "./initializers/**"
require "../src/models/*"
require "../src/jobs/*"
