class Jq
  macro mapping(properties)
    def self.from_json(string : String)
      new(JSON.parse(string))
    end

    {% for key, tuple in properties %}
      def {{key.id}}=(_{{key.id}} : {{tuple[0]}})
        @{{key.id}} = _{{key.id}}
      end

      def {{key.id}}
        @{{key.id}}
      end
    {% end %}

    def initialize(%any : JSON::Any)
      q = Jq.new(%any)

      {% for key, tuple in properties %}
        @{{key.id}} = uninitialized {{tuple[0]}}
        case (v = q[{{tuple[1]}}].raw)
        when {{tuple[0]}}
          @{{key.id}} = v
        else
          raise Jq::ParseException.new("`#{{{tuple[1]}}}' expected #{{{tuple[0]}}}, but got #{v.class}")
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
  end
end
