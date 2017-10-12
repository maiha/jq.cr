module Jq::Cast
  macro cast(klass, hint)
    begin
      {{yield}}
    rescue err : TypeCastError
      {% if hint.is_a?(Nil) %}
        raise Jq::CastError.new(err)
      {% else %}
        raise Jq::CastError.new("`%s' exepected %s, but %s" % [{{hint}}, {{klass}}, err])
      {% end %}
    end
  end

  # TODO: write document why this needs 'not_nil!'.
  def cast(klass : Int64.class, hint : String? = nil)
    cast(klass, hint) { @any.not_nil!.as_i64 }
  end
  
  def cast(klass : Int32.class, hint : String? = nil)
    cast(klass, hint) { @any.not_nil!.as_i }
  end
  
  def cast(klass : Float64.class, hint : String? = nil)
    cast(klass, hint) {
      if @any.as_i64?
        @any.as_i64.to_f64
      elsif @any.as_i?
        @any.as_i.to_f64
      else
        @any.not_nil!.as_f
      end
    }
  end
  
  def cast(klass : Float32.class, hint : String? = nil)
    cast(klass, hint) {
      if @any.as_i64?
        @any.as_i64.to_f32
      elsif @any.as_i?
        @any.as_i.to_f32
      else
        @any.not_nil!.as_f.to_f32
      end
    }
  end
  
  def cast(klass : String.class, hint : String? = nil)
    cast(klass, hint) { @any.not_nil!.as_s }
  end
  
  def cast(klass : Bool.class, hint : String? = nil)
    cast(klass, hint) { @any.not_nil!.as_bool }
  end
  
  def cast(klass : Nil.class, hint : String? = nil)
    cast(klass, hint) { @any.as_nil }
  end

  def cast(klass : Time.class, hint : String? = nil)
    cast(klass, hint) { Pretty::Time.parse(v = cast(String)) }
  end
  
  def cast(klass : Class, hint : String? = nil)
    klass.from_json(@any.to_json)
#    raise CastError.new("no cast methods for #{klass}", hint : String? = nil)
  end
end

class Jq
  include Cast
end
