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

    return call_next(context) unless trackable?(context.request)

    visitor = track_visitor(context, user_agent)
    started_at = Time.instant

    call_next(context)

    track_event(context, visitor, Time.instant - started_at) if visitor
  end

  private def track_visitor(context : HTTP::Server::Context, user_agent : String?) : Visitor?
    request = context.request
    visitor_id = visitor_id(request)

    unless visitor_id
      set_visitor_cookie(context, UUID.random)
      return
    end

    remote_address = Helpers.real_ip(request)
    visitor = Visitor.find(visitor_id)

    if visitor
      location = visitor.remote_address == remote_address ? visitor.location : remote_address_location(remote_address)

      visitor.update!({
        remote_address: remote_address,
        user_agent:     user_agent,
        location:       location,
      })
    else
      visitor = Visitor.create!({
        remote_address: remote_address,
        user_agent:     user_agent,
        location:       remote_address_location(remote_address),
      })
    end

    set_visitor_cookie(context, visitor.id)

    visitor
  rescue error
    handle_tracking_error(error)
    nil
  end

  private def set_visitor_cookie(context : HTTP::Server::Context, visitor_id : UUID) : Nil
    visitor_id_cookie = HTTP::Cookie.new(
      name: "visitor_id",
      value: visitor_id.to_s,
      path: "/",
      expires: Time.utc + 365.days,
      secure: ENV["KEMAL_ENV"]? == "production",
      http_only: true,
      samesite: HTTP::Cookie::SameSite::Lax
    )
    context.response.cookies["visitor_id"] = visitor_id_cookie
  end

  private def track_event(context : HTTP::Server::Context, visitor : Visitor, duration : Time::Span) : Nil
    request = context.request

    visitor.events.create!({
      path:        request.path,
      route:       context.route.path,
      method:      request.method,
      params:      request.query_params.to_h,
      referrer:    request.headers["Referer"]?,
      duration_ms: duration.total_milliseconds.round.to_i64,
    })
  rescue error
    handle_tracking_error(error)
  end

  private def handle_tracking_error(error : Exception) : Nil
    if ENV["KEMAL_ENV"]? == "production"
      Raven.capture(error)
    else
      raise error
    end
  end

  private def visitor_id(request : HTTP::Request) : UUID?
    cookie = request.cookies["visitor_id"]?

    cookie.try { |value| UUID.parse?(value.value) }
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
