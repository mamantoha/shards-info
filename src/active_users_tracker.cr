class ActiveUserTracker
  include HTTP::Handler

  def initialize
  end

  def call(context : HTTP::Server::Context)
    user_id = (context.request.cookies["user_id"]?.try(&.value) || UUID.random).to_s

    context.response.cookies["user_id"] = user_id

    remote_address = Helpers.real_ip(context.request)

    value = {
      "remote_address" => remote_address,
    }.to_json

    ACTIVE_USERS_CACHE.write(user_id, value)

    call_next(context)
  end

  def call(env)
    user_id = env.request.cookies["user_id"]? || UUID.random.to_s
    env.response.cookies["user_id"] = user_id

    call_next env
  end
end
