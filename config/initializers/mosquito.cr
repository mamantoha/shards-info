require "mosquito"

log_file =
  case ENV["KEMAL_ENV"]
  when "production"
    File.new("#{__DIR__}/../../log/mosquito.log", "a+")
  else
    STDOUT
  end

Log.builder.bind "mosquito.*", :info, Log::IOBackend.new(log_file)
