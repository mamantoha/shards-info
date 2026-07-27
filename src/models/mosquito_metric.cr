class MosquitoMetric
  include Lustra::Model

  enum Outcome
    Succeeded
    Failed
    Preempted
    Aborted
  end

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

  def self.record(queue_name : String, outcome : Outcome, runtime : Time::Span) : Nil
    processed = outcome.succeeded? || outcome.failed?

    query = Lustra::SQL.insert_into(full_table_name, {
      day:        Time.utc.to_s("%F"),
      queue_name: queue_name,
      succeeded:  outcome.succeeded? ? 1_i64 : 0_i64,
      failed:     outcome.failed? ? 1_i64 : 0_i64,
      preempted:  outcome.preempted? ? 1_i64 : 0_i64,
      aborted:    outcome.aborted? ? 1_i64 : 0_i64,
      runtime_ms: processed ? runtime.total_milliseconds.round.to_i64 : 0_i64,
    })

    query
      .on_conflict(%(("queue_name", "day")))
      .do_update do |update|
        update.set(<<-SQL)
          "succeeded" = #{full_table_name}."succeeded" + excluded."succeeded",
          "failed" = #{full_table_name}."failed" + excluded."failed",
          "preempted" = #{full_table_name}."preempted" + excluded."preempted",
          "aborted" = #{full_table_name}."aborted" + excluded."aborted",
          "runtime_ms" = #{full_table_name}."runtime_ms" + excluded."runtime_ms",
          "updated_at" = NOW()
          SQL
      end
      .execute
  end
end
