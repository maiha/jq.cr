require "./spec_helper"

module Mapping::Generic
  class ArrayWithType
    Jq.mapping({
      items: Array(String),
      items_with_tuple: {Array(String), ".items"},
    })
  end

  it "works with generic class" do
    json = <<-EOF
      {
        "items":["foo", "bar"]
      }
    EOF

    user = ArrayWithType.from_json(json)
    user.items.should eq(["foo", "bar"])
    user.items_with_tuple.should eq(["foo", "bar"])
  end
end
