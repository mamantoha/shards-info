require "lustra/cli"
require "./cli/tools"

require "../config/config"

module Lustra
  module CLI
    class Base < Admiral::Command
      register_sub_command tools, type: Lustra::CLI::Tools
    end
  end
end

Lustra::CLI.run
