require "json"

class Jq
  record Query, trace : String, f : (JSON::Any -> JSON::Any) do
    def apply(any : JSON::Any) : JSON::Any
      proc = Proc(JSON::Any, JSON::Any).new(f.pointer, f.closure_data)
      proc.call(any)
    end

    def self.attr(trace : String, key) : Query
      Query.new(trace, ->(x : JSON::Any) { x[key] })
    end

    def self.const(trace : String, val : JSON::Type) : Query
      Query.new(trace, ->(x : JSON::Any) { JSON::Any.new(val) })
    end
  end
end
