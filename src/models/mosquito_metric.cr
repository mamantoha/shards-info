class MosquitoMetric
  include Lustra::Model

  enum Outcome
    Succeeded
    Failed
    Preempted
    Aborted
  end

  struct Summary
    getter succeeded : Int64
    getter failed : Int64
    getter preempted : Int64
    getter aborted : Int64
    getter runtime_ms : Int64

    def initialize(
      @succeeded : Int64,
      @failed : Int64,
      @preempted : Int64,
      @aborted : Int64,
      @runtime_ms : Int64,
    )
    end

    def processed : Int64
      succeeded + failed
    end

    def average_runtime_ms : Float64
      return 0.0 if processed.zero?

      runtime_ms.to_f / processed
    end
  end

  struct HistoryPoint
    getter day : String
    getter processed : Int64
    getter failed : Int64

    def initialize(@day : String, @processed : Int64, @failed : Int64)
    end
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

  def self.summary(queue_name : String? = nil) : Summary
    query = summary_query
    query.where({queue_name: queue_name}) if queue_name

    summary_from(query.fetch_first!)
  end

  def self.summaries_by_queue : Hash(String, Summary)
    summaries = {} of String => Summary

    summary_query
      .select("queue_name")
      .group_by("queue_name")
      .fetch do |row|
        summaries[row["queue_name"].as(String)] = summary_from(row)
      end

    summaries
  end

  def self.history(days : Int32, queue_name : String? = nil) : Array(HistoryPoint)
    start_day = Time.utc - (days - 1).days
    points_by_day = {} of String => HistoryPoint

    query = self.query
      .select({
        day:       "day",
        succeeded: "SUM(succeeded)::bigint",
        failed:    "SUM(failed)::bigint",
      })
      .where("day >= ?", start_day.to_s("%F"))
      .group_by("day")
      .order_by("day")

    query.where({queue_name: queue_name}) if queue_name

    query.fetch do |row|
      day = row["day"].as(Time).to_s("%F")
      succeeded = row["succeeded"].as(Int64)
      failed = row["failed"].as(Int64)
      points_by_day[day] = HistoryPoint.new(day, succeeded + failed, failed)
    end

    Array.new(days) do |offset|
      day = (start_day + offset.days).to_s("%F")
      points_by_day[day]? || HistoryPoint.new(day, 0_i64, 0_i64)
    end
  end

  private def self.summary_query
    query
      .select({
        succeeded:  "COALESCE(SUM(succeeded), 0)::bigint",
        failed:     "COALESCE(SUM(failed), 0)::bigint",
        preempted:  "COALESCE(SUM(preempted), 0)::bigint",
        aborted:    "COALESCE(SUM(aborted), 0)::bigint",
        runtime_ms: "COALESCE(SUM(runtime_ms), 0)::bigint",
      })
  end

  private def self.summary_from(row) : Summary
    Summary.new(
      succeeded: row["succeeded"].as(Int64),
      failed: row["failed"].as(Int64),
      preempted: row["preempted"].as(Int64),
      aborted: row["aborted"].as(Int64),
      runtime_ms: row["runtime_ms"].as(Int64)
    )
  end
end
