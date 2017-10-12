class Jq
  class Error < Exception
  end

  class NotFound < Error
    property key

    def initialize(@key : String)
      super("Not Found: `#{key}'")
    end
  end

  class CastError < Error
  end
end
