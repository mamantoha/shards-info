require "kilt"

# Since Kemal 1.2 Kilt removed as dependency
# https://github.com/kemalcr/kemal/issues/617
#
# These 2 macros restores removed functionality.

macro render(filename, layout)
  __content_filename__ = {{filename}}
  content = render {{filename}}
  render {{layout}}
end

macro render(filename)
  Kilt.render({{filename}})
end

module Kemal
  # :nodoc:
  class FilterHandler
    # FIXME: https://github.com/kemalcr/kemal/pull/564
    private def radix_path(verb : String?, path : String, type : Symbol)
      "/#{type}/#{verb.upcase}/#{path}"
    end
  end
end
