require "json"

# for debugging
class Jq
  def simulate(filter : String)
    current = any
    traces = [] of String
    parse(filter).each_with_index do |q, i|
      traces << q.trace
      puts "#" * 50
      puts "### Step: #{i+1}"
      puts "current: #{current.inspect}"
      puts "   type: #{current.raw.class}"
      puts "query: #{q.inspect}"
      puts "trace: #{q.trace} of #{traces.join}"
      result = q.apply(current)
      puts "executed: #{result.inspect}"
      puts "    type: #{result.raw.class}"
      current = result
    end
  end
end
