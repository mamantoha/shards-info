require "mosquito"

module ErrorHandler
  macro included
    after do
      return unless failed?

      # Capture the exception in Sentry with Raven - https://github.com/sija/raven.cr
      exception.try { |e| Raven.capture(e) }
    end
  end
end

class PeriodicJobWithErrorHandler < Mosquito::PeriodicJob
  include ErrorHandler
end

class MosquitoQueuedJobWithErrorHandler < Mosquito::QueuedJob
  include ErrorHandler
end

Mosquito.configure do |settings|
  settings.idle_wait = 10.seconds
  settings.redis_url = ENV["MOSQUITO_REDIS_URL"]
end
