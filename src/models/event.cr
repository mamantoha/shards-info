class Event
  include Lustra::Model

  primary_key

  belongs_to visitor : Visitor, foreign_key_type: UUID, counter_cache: true, touch: true

  column path : String
  column route : String
  column method : String
  column params : JSON::Any, presence: false
  column referrer : String?
  column duration_ms : Int64

  timestamps
end
