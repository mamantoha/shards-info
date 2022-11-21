require "clear/cli"
require "./cli/tools"

require "../config/config"

module Clear
  module CLI
    class Base < Admiral::Command
      register_sub_command tools, type: Clear::CLI::Tools
    end
  end
end

Clear::CLI.run
