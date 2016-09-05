require "json"

class Jq
  class NotFound < Exception
    def self.from_key(key : String)
      new("Not Found: `#{key}'")
    end
  end
end

require "./jq/*"
