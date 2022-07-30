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

# Workaround for https://github.com/kemalcr/kemal/issues/643
module Kemal
  class StaticFileHandler < HTTP::StaticFileHandler
    private def modification_time(file_path)
      File.info(file_path).modification_time
    end
  end
end
