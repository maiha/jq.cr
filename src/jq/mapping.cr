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

      def {{key.id}}=(_{{key.id}} : {{tuple[0]}})
        @{{key.id}} = _{{key.id}}
      end

      protected def default_{{key.id}}
        raise Jq::NotFound.new({{key.id.stringify}})
      end

      def {{key.id}}
        if @{{key.id}}.nil?
          default_{{key.id}}
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
          v = q[{{tuple[1]}}]?.try(&.raw)

          if v.nil?
            @{{key.id}} = nil
          elsif v.is_a?({{tuple[0]}})
            @{{key.id}} = v.as({{tuple[0]}})
          elsif {{tuple[0]}} == ::Time && v.is_a?(String)
            @{{key.id}} = jq_parse_as_time(hint, v, {{tuple[2]}})
          else
            # rescue the case of Array(T)
            begin
              {% if tuple[0].stringify == "Array(String)" %}
                @{{key.id}} = jq_cast_array_string(v)
              {% elsif tuple[0].stringify == "Array(Int64)" %}
                @{{key.id}} = jq_cast_array_int64(v)
              {% elsif tuple[0].stringify == "Array(Int32)" %}
                @{{key.id}} = jq_cast_array_int32(v)
              {% else %}
                raise "can't cast"
              {% end %}
            rescue err
              raise Jq::ParseError.new("mapping: `#{hint}' expected #{{{tuple[0]}}}, but got #{v.class} (#{err})")
            end
          end
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

    protected def jq_parse_as_time(hint, v, fmt : String? = "%F")
      Time.parse(v, fmt.not_nil!)
    rescue err
      raise Jq::ParseError.new("`#{hint}' #{err} (input: #{v})")
    end
  end
end
