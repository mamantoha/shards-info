Log.setup do |c|
  clear_log_file =
    case ENV["KEMAL_ENV"]
    when "production"
      File.new("#{__DIR__}/../../log/clear.log", "a+")
    else
      STDOUT
    end

  mosquito_log_file =
    case ENV["KEMAL_ENV"]
    when "production"
      File.new("#{__DIR__}/../../log/mosquito.log", "a+")
    else
      STDOUT
    end

  kemal_log_file =
    case ENV["KEMAL_ENV"]
    when "production"
      File.new("#{__DIR__}/../../log/kemal.log", "a+")
    else
      STDOUT
    end

  cache_log_file =
    case ENV["KEMAL_ENV"]
    when "production"
      File.new("#{__DIR__}/../../log/cache.log", "a+")
    else
      STDOUT
    end


  c.bind "kemal.*", :debug, Log::IOBackend.new(kemal_log_file)
  c.bind "clear.*", :debug, Log::IOBackend.new(clear_log_file)
  c.bind "mosquito.*", :debug, Log::IOBackend.new(mosquito_log_file)
  c.bind "cache.*", :debug, Log::IOBackend.new(cache_log_file)
end
