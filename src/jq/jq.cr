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
    if err.message =~ /Missing/
      raise NotFound.new("`#{trace + query.trace}' #{err}")
    else
      raise ParseError.new("`#{trace + query.trace}' #{err}")
    end
  end

  def []?(filter : String) : Jq?
    self[filter]
  rescue err
    if err.message =~ /Missing/
      return nil
    else
      raise err
    end
  end
  
  {% for name in %w( nil bool i i64 f f32 s a h ) %}
    def as_{{name.id}}
      @any.not_nil!.as_{{name.id}}
    end
  {% end %}
  
  {% for name in %w( bool? i? i64? f? f32? s? a? h? ) %}
    def as_{{name.id}}
      @any.as_{{name.id}}
    end
  {% end %}
end
