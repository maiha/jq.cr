require "./spec_helper"
require "../src/jq"

describe Jq do
  load_grouped_suits.each do |suit_file, suits|
    describe suit_file do
      lm = Math.max(20, suits.map(&.program.size).max + 2)
      suits.each do |suit|
        test_name = %(%6s:  %-#{lm}s => %s) % [suit.program_line.no, suit.program, suit.expected.inspect]
        it test_name do
          begin
            Jq.new(suit.input)[suit.program].raw.should eq(suit.expected)
          rescue err : Jq::ParseError
            # pretty error reporting
            err.to_s.should eq(suit.expected)
          end
        end
      end
    end
  end
end
