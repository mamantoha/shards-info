require "dotenv"
require "mosquito"

Dotenv.load

require "./initializers/**"
require "../src/models/*"
require "../src/jobs/*"
