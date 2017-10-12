class Jq
  class ParseError < Exception
  end

  def self.parse(source : String) : Array(Query)
    array = [] of Query
    s = source
    loop do
      case s.strip
      when /\A\.(\w+)(.*)\Z/ # ".foo"
        array << Query::Attr.new(".#{$1}", $1)
        s = $2
      when /\A\."(\w+)"(.*)\Z/ # ".foo"
        array << Query::Attr.new(".#{$1}", $1)
        s = $2
      when /\A\[\](.*)\Z/ # "[]"
        array << Query::ToArray.new("[]")
        s = $1
      when /\A\[(\d+?)\](.*)\Z/ # "[0]"
        array << Query::Attr.new("[#{$1}]", $1.to_i)
        s = $2
      when /\A\.\["(\w+?)"\](.*)\Z/ # ".[foo]"
        array << Query::Attr.new("[#{$1}]", $1)
        s = $2
      when ""
        break
      when /(.*)/
        s = $1
        begin
          array << Query::Const.new(s, JSON.parse(s).raw)
          break
        rescue
          trace = array.map(&.trace).join
          raise ParseError.new("parse error: after '#{trace}' from '#{source}'")
        end
      end
    end
    return array
  end
end
