class Event
  include Lustra::Model

  primary_key

  belongs_to visitor : Visitor, foreign_key_type: UUID, counter_cache: true

  column path : String
  column method : String
  column params : JSON::Any, presence: false

  timestamps
end
