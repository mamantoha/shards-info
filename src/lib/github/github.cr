require "./*"

module Github
  class_property logger : Logger = Github::Logger.new(STDOUT)
end
