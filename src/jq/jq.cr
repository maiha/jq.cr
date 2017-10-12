require "./jq/*"

class Jq
  getter any
  getter trace
  delegate raw, to: any
  delegate parse, to: self.class
  
  def initialize(@any : JSON::Any, @trace : String = "")
  end

  def initialize(str : String)
    initialize(JSON.parse(str))
  end
end
