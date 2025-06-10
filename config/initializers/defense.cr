require "defense"

Defense.store = if ENV["DEFENSE_REDIS_URL"]?.nil?
                  Defense::MemoryStore.new
                else
                  Defense::RedisStore.new(url: ENV["DEFENSE_REDIS_URL"])
                end

def real_ip(request : HTTP::Request)
  # Try to get IP from headers set by NGINX
  real_ip = request.headers["X-Forwarded-For"]?
  real_ip = real_ip.split(",").first.strip if real_ip

  # Fallbacks
  real_ip ||= request.headers["X-Real-IP"]?
  real_ip ||= case remote_address = request.remote_address
              when Socket::IPAddress
                remote_address.address
              else
                remote_address.to_s
              end
end

Defense.throttle("throttle requests per minute", limit: 45, period: 60) do |request|
  real_ip(request)
end

Defense.throttled_response = ->(response : HTTP::Server::Response) do
  response.status = HTTP::Status::TOO_MANY_REQUESTS
  response.content_type = "text/html"
  response.headers.add "Retry-After", "60"

  response.print(<<-HTML)
  <html>
    <head>
      <title>Too Many Requests</title>
    </head>
    <body>
      <h1>Too Many Requests</h1>
      <p>You're doing that too often! Try again later.</p>
    </body>
  </html>
  HTML
end

Defense.blocklist("fail2ban pentesters") do |request|
  Defense::Fail2Ban.filter("pentesters:#{real_ip(request)}", maxretry: 5, findtime: 60, bantime: 24 * 60 * 60) do
    [
      "/wp-admin",
      "/wp-content",
      "/wp-includes",
      "/.git",
      "/.ssh",
    ].any? { |path| request.path.starts_with?(path) }
  end
end
