require "./spec_helper"

describe "Jq#cast" do
  context "(Float64)" do
    it "accept 0.0" do
      jq = Jq.new(%({"age": 0.0}))
      jq[".age"].cast(Float64)
    end

    it "accept 0" do
      jq = Jq.new(%({"age": 0}))
      jq[".age"].cast(Float64)
    end
  end

  context "(Float32)" do
    it "accept 0.0" do
      jq = Jq.new(%({"age": 0.0}))
      jq[".age"].cast(Float32)
    end

    it "accept 0" do
      jq = Jq.new(%({"age": 0}))
      jq[".age"].cast(Float32)
    end
  end
end
