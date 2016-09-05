require "./spec_helper"
require "../src/jq"

describe Jq do
  describe "[]" do
    it "parses JSON::Any by given filter string" do
      str = %({"name": "Hi", "any": [{"x": 1}, 2, "hey", true, false, 1.5, null]})
      q = Jq.new(str)
      q[".name"].raw.should eq("Hi")
      q[".name"].raw.should eq("Hi") # twice on purpose

      q[".any[1]"].raw.should eq(2)
      q[".any"]["[1]"].raw.should eq(2)
    end

    it "raises ParseError when broken filter string is given" do
      str = %({"name": "Hi", "any": [{"x": 1}, 2, "hey", true, false, 1.5, null]})
      q = Jq.new(str)

      expect_raises(Jq::ParseError) { q["[name["] }
      expect_raises(Jq::ParseError) { q[".."] }
    end

    it "raises when given filter key doesn't exist" do
      str = %({"name": "Hi", "any": [{"x": 1}, 2, "hey", true, false, 1.5, null]})
      q = Jq.new(str)

      expect_raises Jq::NotFound, "`.foo' Missing hash key: " do
        q[".foo"]
      end
    end

    it "raises when method name is correct but args are wrong" do
      str = %({"name": "Hi", "any": [{"x": 1}, 2, "hey", true, false, 1.5, null]})
      q = Jq.new(str)

      expect_raises Jq::ParseError do
        q[".any.x"]
      end
    end
  end
end
