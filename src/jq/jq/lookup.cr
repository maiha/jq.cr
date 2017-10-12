class Jq
  def [](filter : String) : Jq
    parse(filter).reduce(self) { |jq, query| jq[query] }
  end

  def [](query : Query) : Jq
    Jq.new(query.apply(any), trace + query.trace)
  rescue err
    if err.message =~ /Missing/
      raise NotFound.new("`#{trace + query.trace}' #{err}")
    else
      raise ParseError.new("`#{trace + query.trace}' #{err}")
    end
  end

  def []?(filter : String) : Jq?
    self[filter]
  rescue err
    if err.message =~ /Missing/
      return nil
    else
      raise err
    end
  end
end
