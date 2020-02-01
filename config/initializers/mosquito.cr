require "mosquito"

log_file =
  case ENV["KEMAL_ENV"]
  when "production"
    File.new("#{__DIR__}/../../log/mosquito.log", "a+")
  else
    STDOUT
  end

Mosquito::Base.logger = Logger.new(log_file)
