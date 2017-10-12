class Jq
  macro mapping(properties)
    # First, normalize property structure for following formats.
    # (before)
    #   key1:  String,
    #   key2: {String, ".key2"},
    #   key3: {Time, ".key3", "%FT%T"},
    # (after)
    #   key1: {String, ".key1"},
    #   key2: {String, ".key2"},
    #   key3: {Time, ".key3", "%FT%T"},
    {% for key, tuple in properties %}
      {% properties[key] = {tuple, ".#{key.id}"} if tuple.is_a?(Path) %}
    {% end %}

    def self.from_json(string : String)
      new(::JSON.parse(string))
    end

    def self.new(pull : JSON::PullParser)
      new(JSON::Any.new(pull))
    end

    {% for key, tuple in properties %}
      @{{key.id}} : {{tuple[0].id}}?

      def {{key.id}}=(value : {{tuple[0]}})
        @{{key.id}} = value
      end

      protected def default_{{key.id}}
        raise Jq::NotFound.new({{key.id.stringify}})
      end

      def {{key.id}}
        if @{{key.id}}.nil?
          {% if tuple[0].stringify =~ /^Array\(/ %}
            {{tuple[0]}}.new
          {% else %}
            default_{{key.id}}
          {% end %}
        else
          @{{key.id}}.not_nil!
        end
      end

      def {{key.id}}?
        @{{key.id}}
      end
    {% end %}

    def initialize(%any : ::JSON::Any)
      q = Jq.new(%any)

      {% for key, tuple in properties %}
        begin
          hint = {{tuple[1]}}
          @{{key.id}} = q[{{tuple[1]}}]?.try(&.cast({{tuple[0]}}, hint))
        end
      {% end %}
    end

    def to_json(json : JSON::Builder)
      json.object do
        {% for key, tuple in properties %}
          _{{key.id}} = @{{key.id}}
          json.field({{key.id.stringify}}) do
            _{{key.id}}.to_json(json)
          end
        {% end %}
      end
    end

    protected def jq_cast_array_string(x) : Array(String)
      case x
      when Array
        x.map(&.to_s)
      else
        raise "no cast support for #{x.class}"
      end
    end

    protected def jq_cast_array_int32(x) : Array(Int32)
      jq_cast_array_int64(x).map(&.to_i32)
    end

    protected def jq_cast_array_int64(x) : Array(Int64)
      case x
      when Array
        x.map{|i|
          if i.is_a?(Int64)
            i.as(Int64)
          else
            raise ""
          end
        }
      else
        raise "no cast support for #{x.class}"
      end
    end
  end
end
