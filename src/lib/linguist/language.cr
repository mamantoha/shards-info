require "yaml"

# https://github.com/github/linguist
module Linguist
  # Languages are defined in `languages.yml`.
  class Language
    @@languages = [] of Language
    @@name_index = {} of String => Language

    getter name
    # a hex color String
    getter color

    def initialize(@name : String, @color : String?)
    end

    # Look up Language by its proper name.
    #
    # ```
    # Linguist::Language.find_by_name("ruby")
    # => #<Linguist::Language:0x7f9f83175e80 @name="Ruby", @color="#701516">
    # ```
    def self.find_by_name(name : String) : Language?
      return if name.empty?

      @@name_index[name.downcase]?
    end

    def self.create(name, color) : Language
      language = new(name, color)

      @@languages << language

      @@name_index[language.name.downcase] = language

      language
    end

    # Get all Languages
    def self.all : Array(Language)
      @@languages
    end

    # A List of languages with assigned colors.
    def self.colors : Array(Language)
      all.select(&.color).sort_by { |lang| lang.name.downcase }
    end
  end

  languages = File.open("#{__DIR__}/languages.yml") do |file|
    YAML.parse(file)
  end

  languages.as_h.each do |name, options|
    color = options["color"]? ? options["color"].to_s : nil

    Language.create(
      name: name.as_s,
      color: color
    )
  end
end
