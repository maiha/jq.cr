require "./spec_helper"

module Mapping::ToH
  class Foo
    Jq.mapping({
      a: Int64,
      b: String,
    })
  end

  it "provides to_h" do
    json = <<-EOF
      {
        "a":1,
        "b":"foo"
      }
    EOF

    foo = Foo.from_json(json)
    foo.to_h.should eq({"a" => 1, "b" => "foo"})
  end
end
