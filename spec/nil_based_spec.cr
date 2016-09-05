require "./spec_helper"
require "../src/jq"

describe Jq do
  describe "[]?" do
    str = %({"foo": "1"})
    jq = Jq.new(str)

    it "returns jq value if present" do
      jq[".foo"]?.try(&.raw).should eq("1")
    end

    it "returns nil if absent" do
      jq[".xxx"]?.should eq(nil)
    end
  end
end
