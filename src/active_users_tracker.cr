require "device_detector"
require "ipapi"

class ActiveUserTracker
  include HTTP::Handler

  def initialize
  end

  def call(context : HTTP::Server::Context)
    user_agent = context.request.headers["User-Agent"]?

    if user_agent
      device = DeviceDetector::Detector.new(user_agent).call

      return call_next(context) if device.bot?
    end

    if context.request.cookies["user_id"]?
      user_id = context.request.cookies["user_id"]?.try(&.value)

      return call_next(context) unless user_id

      remote_address = Helpers.real_ip(context.request)

      location = remote_address_location(remote_address)

      value = {
        "remote_address" => remote_address,
        "user_agent"     => user_agent || "unknown",
        "location"       => JSON.parse(location),
      }.to_json

      ACTIVE_USERS_CACHE.write(user_id, value)

      call_next(context)
    else
      user_id = UUID.random.to_s
      user_id_cookie = HTTP::Cookie.new("user_id", user_id, path: "/")
      context.response.cookies["user_id"] = user_id_cookie
      call_next(context)
    end
  end

  private def remote_address_location(remote_address : String) : String
    if Socket::IPAddress.valid?(remote_address)
      ip_address = Socket::IPAddress.new(remote_address, 0)

      if ip_address.loopback? || ip_address.private?
        "{}"
      else
        IPAPI_CACHE.fetch(remote_address) do
          ipapi_client = Ipapi::Client.new
          ipapi_client.locate(remote_address).to_json rescue "{}"
        end
      end
    else
      "{}"
    end
  end
end
