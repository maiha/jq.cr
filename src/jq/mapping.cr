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

    {% for key, tuple in properties %}
      def {{key.id}}=(_{{key.id}} : {{tuple[0]}})
        @{{key.id}} = _{{key.id}}
      end

      def {{key.id}}
        @{{key.id}}
      end
    {% end %}

    def initialize(%any : ::JSON::Any)
      q = Jq.new(%any)

      {% for key, tuple in properties %}
        @{{key.id}} = uninitialized {{tuple[0]}}
        case (v = q[{{tuple[1]}}].raw)
        when {{tuple[0]}}
          @{{key.id}} = v
        else
          hint = {{tuple[1]}}
          if {{tuple[0]}} == ::Time && v.is_a?(String)
            @{{key.id}} = jq_parse_as_time(hint, v, {{tuple[2]}})
          else
            raise Jq::ParseException.new("mapping: `#{hint}' expected #{{{tuple[0]}}}, but got #{v.class}")
          end
        end
      {% end %}
    end

    def to_json(io : IO)
      io.json_object do |json|
        {% for key, tuple in properties %}
          _{{key.id}} = @{{key.id}}
          json.field({{key.id.stringify}}) do
            _{{key.id}}.to_json(io)
          end
        {% end %}
      end
    end

    protected def jq_parse_as_time(hint, v, fmt : String? = "%F")
      Time.parse(v, fmt.not_nil!)
    rescue err
      raise Jq::ParseException.new("`#{hint}' #{err} (input: #{v})")
    end
  end
end
