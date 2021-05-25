# https://github.com/kemalcr/kemal/pull/612
module Kemal
  class FilterHandler
    private def radix_path(verb : String?, path : String, type : Symbol)
      "/#{type}/#{verb}/#{path}"
    end
  end
end
