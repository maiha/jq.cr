class Jq
  class ParseException < Exception
  end

  def self.parse(source : String) : Array(Query)
    array = [] of Query
    s = source
    loop do
      case s.strip
      when /\A\.(\w+)(.*)\Z/ # ".foo"
        array << Query.attr(".#{$1}", $1)
        s = $2
      when /\A\."(\w+)"(.*)\Z/ # ".foo"
        array << Query.attr(".#{$1}", $1)
        s = $2
      when /\A\[(\d+?)\](.*)\Z/ # "[0]"
        array << Query.attr("[#{$1}]", $1.to_i)
        s = $2
      when /\A\.\["(\w+?)"\](.*)\Z/ # ".[foo]"
        array << Query.attr("[#{$1}]", $1)
        s = $2
      when ""
        break
      when /(.*)/
        s = $1
        begin
          array << Query.const(s, JSON.parse(s).raw)
          break
        rescue
          trace = array.map(&.trace).join
          raise ParseException.new("parse error: after '#{trace}' from '#{source}'")
        end
      end
    end
    return array
  end
end
