require "./*"

module Forgejo
  class_property logger : Logger = Forgejo::Logger.new(STDOUT)
end
