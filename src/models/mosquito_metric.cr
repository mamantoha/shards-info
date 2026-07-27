class MosquitoMetric
  include Lustra::Model

  primary_key

  column day : Time
  column queue_name : String
  column succeeded : Int64
  column failed : Int64
  column preempted : Int64
  column aborted : Int64
  column runtime_ms : Int64

  timestamps

  def processed : Int64
    succeeded + failed
  end

  def average_runtime_ms : Float64
    return 0.0 if processed.zero?

    runtime_ms.to_f / processed
  end
end
