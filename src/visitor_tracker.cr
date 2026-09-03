require "device_detector"
require "ipapi"

class VisitorTracker
  include HTTP::Handler

  def initialize
  end

  def call(context : HTTP::Server::Context)
    user_agent = context.request.headers["User-Agent"]?

    if user_agent
      device = DeviceDetector::Detector.new(user_agent).call

      return call_next(context) if device.bot?
    end

    track(context, user_agent) if trackable?(context.request)
    call_next(context)
  end

  private def track(context : HTTP::Server::Context, user_agent : String?) : Nil
    request = context.request
    remote_address = Helpers.real_ip(request)
    visitor = find_visitor(request)

    if visitor
      location = visitor.remote_address == remote_address ? visitor.location : remote_address_location(remote_address)

      visitor.update!({
        remote_address: remote_address,
        user_agent:     user_agent,
        location:       location,
        updated_at:     Time.local,
      })
    else
      visitor = Visitor.create!({
        remote_address: remote_address,
        user_agent:     user_agent,
        location:       remote_address_location(remote_address),
      })

      visitor_id_cookie = HTTP::Cookie.new("visitor_id", visitor.id.to_s, path: "/")
      context.response.cookies["visitor_id"] = visitor_id_cookie
    end

    visitor.events.create!({
      path:   request.path,
      method: request.method,
      params: JSON.parse(request.query_params.to_h.to_json),
    })
  rescue
  end

  private def find_visitor(request : HTTP::Request) : Visitor?
    cookie = request.cookies["visitor_id"]?
    visitor_id = cookie.try { |value| UUID.parse?(value.value) }

    Visitor.find(visitor_id) if visitor_id
  end

  private def trackable?(request : HTTP::Request) : Bool
    return false if request.path.starts_with?("/admin")

    request.headers["Accept"]?.try(&.includes?("text/html")) || false
  end

  private def remote_address_location(remote_address : String) : JSON::Any
    if Socket::IPAddress.valid?(remote_address)
      ip_address = Socket::IPAddress.new(remote_address, 0)

      if ip_address.loopback? || ip_address.private?
        JSON.parse("{}")
      else
        location = IPAPI_CACHE.fetch(remote_address) do
          ipapi_client = Ipapi::Client.new
          ipapi_client.locate(remote_address).to_json rescue "{}"
        end

        JSON.parse(location)
      end
    else
      JSON.parse("{}")
    end
  end
end
