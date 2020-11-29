require "mosquito"

Mosquito.configure do |settings|
  settings.redis_url = ENV["REDIS_URL"]
end

log_file =
  case ENV["KEMAL_ENV"]
  when "production"
    File.new("#{__DIR__}/../../log/mosquito.log", "a+")
  else
    STDOUT
  end

Log.builder.bind "mosquito.*", :info, Log::IOBackend.new(log_file)
