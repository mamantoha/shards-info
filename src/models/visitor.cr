class Visitor
  include Lustra::Model

  column id : UUID, primary: true, presence: false
  column remote_address : String
  column user_agent : String?
  column location : JSON::Any
  column events_count : Int64, presence: false

  timestamps

  has_many events : Event
end
