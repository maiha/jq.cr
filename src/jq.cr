require "json"

class Jq
  class NotFound < Exception
    property key

    def initialize(@key : String)
      super("Not Found: `#{key}'")
    end
  end
end

require "./jq/*"
