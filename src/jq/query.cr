require "json"

class Jq
  module Query
    abstract def trace() : String
    abstract def apply(any : JSON::Any) : JSON::Any

    class Lambda
      include Query

      getter trace

      def initialize(@trace : String, @func : (JSON::Any -> JSON::Any))
      end

      def apply(any : JSON::Any)
        @func.call(any)
      end
    end

    class Attr
      include Query

      getter trace

      def initialize(@trace : String, @key : (Int32 | String))
      end

      def apply(x : Array(JSON::Any), i : Int32) : JSON::Any
        x[i]
      end
      
      def apply(x : Array(JSON::Any), key : String) : Array(JSON::Any)
        v = x.map{|e|
          case e.raw
          when Hash
            e[key].as(JSON::Any)
          when Array
            e[key.to_i].as(JSON::Any)
          else
            raise "invalid [#{key}] access to #{e.class}"
          end
        }.map(&.as(JSON::Any)).as(Array(JSON::Any))
      end

      def apply(x : Array(JSON::Any), key) : JSON::Any
        raise "invalid [#{key}(#{key.class})] access to Array"
      end
      
      def apply(x : JSON::Any) : JSON::Any
        if x.raw.is_a?(Array)
          # x: [{"s" => "foo"}, {"s" => "bar"}]
          # @key: "s"
          v = apply(x.as_a, @key)
          case v
          when JSON::Any
            return v
          when Array(JSON::Any)
            return JSON::Any.new(v)
          else
            raise "Expected 'Array(JSON::Any)' or 'JSON::Any', but got #{v.class})"
          end
        else
          return x[@key].as(JSON::Any)
        end
      end

      def to_s(io : IO)
        io << "[#{@key.inspect}]"
      end

      def inspect(io : IO)
        io << "Jq::Query::Attr(#{to_s}, @trace='#{trace}')"
      end
    end

    class Const
      include Query

      getter trace

      def initialize(@trace : String, @val : JSON::Any)
      end

      def apply(x : JSON::Any)
        @val
      end
    end

    class ToArray
      include Query

      getter trace

      def initialize(@trace : String)
      end

      def apply(x : JSON::Any)
        case x.raw
        when Array
          x.as(JSON::Any)
        else
          # If not array, returns empty array.
          JSON::Any.new(Array(JSON::Any).new)
        end
      end

      def to_s(io : IO)
        io << "[]"
      end

      def inspect(io : IO)
        io << "Jq::Query::ToArray(#{to_s})"
      end
    end
  end
end
