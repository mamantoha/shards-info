class Admin
  include Lustra::Model

  primary_key

  column provider : String
  column uid : String
  column raw_json : String
  column role : Int32
  column name : String?
  column email : String?
  column nickname : String?
  column first_name : String?
  column last_name : String?
  column location : String?
  column image : String?
  column phone : String?

  timestamps

  ROLES = {
    0 => "guest",
    1 => "admin",
  }

  {% for value, name in ROLES %}
    def {{name.id}}? : Bool
      role == {{value.id}}
    end
  {% end %}

  def decorate
    @delegator ||= AdminDelegator.delegate(self)
  end
end
