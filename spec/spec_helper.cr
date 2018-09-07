require "spec"
require "../src/jq"

record Line, no : Int32, buffer : String
record Suit, program_line : Line, input_line : Line, output_line : Line do
  def program : String
    program_line.buffer
  end

  def input : String
    input_line.buffer
  end

  def expected : JSON::Any::Type
    JSON.parse(output_line.buffer).raw
  end
end

def load_grouped_suits : Hash(String, Array(Suit))
  hash = {} of String => Array(Suit)
  Dir["#{__DIR__}/fixtures/*"].sort.map { |full_path|
    suits = [] of Suit
    file = File.basename(full_path)
    lines = File.read_lines(full_path).map_with_index { |line, i| Line.new(i + 1, line.chomp) }
    lines.select! { |line| line.buffer =~ /\A[^#\Z]/ }
    lines.in_groups_of(3) { |ary|
      head = ary.first.not_nil!
      raise "BUG: invalid fixture size #{ary.size} in '#{full_path}':#{head.no}" unless ary.size == 3
      program = ary[0].not_nil!
      input = ary[1].not_nil!
      output = ary[2].not_nil!
      suits << Suit.new(program, input, output)
    }
    hash["fixtures/#{file}"] = suits
  }
  hash
end
