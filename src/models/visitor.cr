class Visitor
  include Lustra::Model

  column id : UUID, primary: true, presence: false
  column remote_address : String
  column user_agent : String?
  column location : JSON::Any
  column events_count : Int64, presence: false

  timestamps

  has_many events : Event

  def self.country_counts(days : Int32) : Hash(String, Int64)
    active_visitors = Event.query
      .select("visitor_id")
      .distinct
      .where("created_at >= ?", Time.utc - days.days)

    counts = {} of String => Int64

    query
      .select("UPPER(COALESCE(location ->> 'country_code', '')) AS country_code", "COUNT(*) AS count")
      .where({id: active_visitors})
      .where("events_count >= ?", 2)
      .group_by("UPPER(COALESCE(location ->> 'country_code', ''))")
      .fetch do |row|
        counts[row["country_code"].as(String)] = row["count"].as(Int64)
      end

    counts
  end
end
