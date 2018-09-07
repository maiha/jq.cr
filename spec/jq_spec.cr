require "./spec_helper"
require "../src/jq"

describe Jq do
  describe "any" do
    it "returns JSON::Any" do
      q = Jq.new(%({"foo": "bar"}))
      json = q.any
      json.should be_a(JSON::Any)
      json["foo"]?.not_nil!.raw.should eq("bar")
    end
  end

  describe "raw" do
    it "returns JSON::Any::Type" do
      q = Jq.new(%({"foo": "bar"}))
      q.raw.should be_a(JSON::Any::Type)
    end
  end
end
