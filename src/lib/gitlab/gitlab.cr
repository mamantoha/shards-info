require "./*"

module Gitlab
  class_property logger : Logger = Gitlab::Logger.new(STDOUT)
end
