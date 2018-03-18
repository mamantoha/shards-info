require "kemal"
require "kilt/slang"
require "cache"

get "/" do
   render "src/views/index.slang", "src/views/layouts/layout.slang"
end

Kemal.run
