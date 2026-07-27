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

module MosquitoMetricsHandler
  Log = ::Log.for("mosquito.metrics")

  macro included
    @mosquito_metrics_started_at : Time::Span?

    before do
      @mosquito_metrics_started_at = Time.monotonic
    end

    after do
      outcome =
        if succeeded?
          MosquitoMetric::Outcome::Succeeded
        elsif failed?
          MosquitoMetric::Outcome::Failed
        elsif preempted?
          MosquitoMetric::Outcome::Preempted
        elsif aborted?
          MosquitoMetric::Outcome::Aborted
        end

      if outcome && (started_at = @mosquito_metrics_started_at)
        begin
          MosquitoMetric.record(self.class.queue_name, outcome, Time.monotonic - started_at)
        rescue error
          MosquitoMetricsHandler::Log.error(exception: error) do
            "Failed to record metrics for #{self.class.queue_name}"
          end
        end
      end
    end
  end
end

class PeriodicJobWithErrorHandler < Mosquito::PeriodicJob
  include MosquitoMetricsHandler
  include ErrorHandler
end

class MosquitoQueuedJobWithErrorHandler < Mosquito::QueuedJob
  include MosquitoMetricsHandler
  include ErrorHandler
end

Mosquito.configure do |settings|
  settings.idle_wait = 10.seconds
  settings.backend_connection_string = ENV["MOSQUITO_REDIS_URL"]
  settings.publish_metrics = true
end
