class Jq
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
