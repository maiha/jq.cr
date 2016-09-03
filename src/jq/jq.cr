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
    raise ParseError.new("`#{trace + query.trace}' #{err}")
  end

  {% for name in %w( nil bool bool? i i? i64 i64? f f? f32 f32? s s? a a? h h? ) %}
    def as_{{name.id}}
      @any.as_{{name.id}}
    end
  {% end %}
end
