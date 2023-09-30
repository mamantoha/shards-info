require "../config/config"

Mosquito::Runner.start

while Mosquito::Runner.keep_running
  sleep 1
end
