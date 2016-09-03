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

      def apply(x : Array(JSON::Type), i : Int32) : JSON::Type
        x[i]
      end
      
      def apply(x : Array(JSON::Type), key : String) : JSON::Type
        v = x.map{|e|
          case e
          when Hash
            e[key].as(JSON::Type)
          when Array
            e[key.to_i].as(JSON::Type)
          else
            raise "invalid [#{key}] access to #{e.class}"
          end
        }.map(&.as(JSON::Type)).as(Array(JSON::Type))
      end

      def apply(x : Array(JSON::Type), key) : JSON::Type
        raise "invalid [#{key}(#{key.class})] access to Array"
      end
      
      def apply(x : JSON::Any)
        if x.raw.is_a?(Array)
          v = apply(x.raw.as(Array(JSON::Type)), @key)
          return JSON::Any.new(v.as(JSON::Type))
        else
          return x[@key].as(JSON::Any)
        end
      end
    end

    class Const
      include Query

      getter trace

      def initialize(@trace : String, @val : JSON::Type)
      end

      def apply(x : JSON::Any)
        JSON::Any.new(@val)
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
          v = ([x.raw].flatten.compact.map(&.as(JSON::Type)))
          JSON::Any.new(v.as(JSON::Type))
        end
      end
    end
  end
end
