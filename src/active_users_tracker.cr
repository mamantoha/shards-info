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

    user_id = (context.request.cookies["user_id"]?.try(&.value) || UUID.random).to_s

    context.response.cookies["user_id"] = user_id

    remote_address = Helpers.real_ip(context.request)

    location = IPAPI_CACHE.fetch(remote_address) do
      ipapi_client = Ipapi::Client.new

      ipapi_client.locate(remote_address).to_json rescue "{}"
    end

    value = {
      "remote_address" => remote_address,
      "user_agent"     => user_agent || "unknown",
      "location"       => JSON.parse(location),
    }.to_json

    ACTIVE_USERS_CACHE.write(user_id, value)

    call_next(context)
  end
end
