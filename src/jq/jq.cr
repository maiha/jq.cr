require "json"

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

  def [](filter : String) : Jq
    parse(filter).reduce(self) { |jq, query| jq[query] }
  end

  def [](query : Query) : Jq
    Jq.new(query.apply(any), trace + query.trace)
  rescue err
    raise ParseException.new("`#{trace + query.trace}' #{err}")
  end
end
