require "./spec_helper"

module Mapping::Cast
  class Strs
    Jq.mapping({
      strs: {Array(String), ".strs[].s"},
    })
  end

  it "supports Array(String)" do
    json = <<-EOF
      {
        "strs":[
          {"s":"foo"},
          {"s":"bar"}
        ]
      }
    EOF
    Strs.from_json(json).strs.should eq(["foo", "bar"])
  end

  class Int32s
    Jq.mapping({
      ints: {Array(Int32), ".ints[].i"},
    })
  end

  it "supports Array(Int32)" do
    json = <<-EOF
      {
        "ints":[
          {"i":1},
          {"i":2}
        ]
      }
    EOF
    Int32s.from_json(json).ints.should eq([1,2])
    Int32s.from_json(json).ints.first.should be_a(Int32)
  end

  class Int64s
    Jq.mapping({
      ints: {Array(Int64), ".ints[].i"},
    })
  end

  it "supports Array(Int64)" do
    json = <<-EOF
      {
        "ints":[
          {"i":1},
          {"i":2}
        ]
      }
    EOF
    Int64s.from_json(json).ints.should eq([1,2])
    Int64s.from_json(json).ints.first.should be_a(Int64)
  end
end
