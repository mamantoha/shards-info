require "../lib/linguist/language"

class Clear::CLI::Tools < Admiral::Command
  include Clear::CLI::Command

  define_help description: "Various tools"

  class UpdateLanguagesColor < Admiral::Command
    include Clear::CLI::Command

    define_help description: "Update languages color"

    def run_impl
      Language.query.each do |language|
        if (linguist_language = Linguist::Language.find_by_name(language.name))
          language.color = linguist_language.color
          language.save!
        end
      end
    end
  end

  def run_impl
    puts help
  end

  register_sub_command update_languages_color, type: UpdateLanguagesColor
end
