class Lustra::CLI::Tools < Admiral::Command
  include Lustra::CLI::Command

  define_help description: "Various tools"

  class UpdateLanguagesColor < Admiral::Command
    include Lustra::CLI::Command

    define_help description: "Update languages color"

    def run_impl
      Helpers.update_languages_color
    end
  end

  def run_impl
    puts help
  end

  register_sub_command update_languages_color, type: UpdateLanguagesColor
end
