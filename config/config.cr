require "dotenv"

Dotenv.load?

require "./initializers/**"
require "../src/macros/*"
require "../src/models/*"
require "../src/helpers/*"
require "../src/jobs/*"
