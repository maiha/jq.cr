require "./spec_helper"

module Example::Nilable
  class Foo
    Jq.mapping({
      k: Int32,
      v: String?,
    })
  end

  describe "Example::Nilable" do
    it "can accept both Int32 and Nil field" do
      reports = Array(Foo).from_json <<-EOF
        [
          {"k": 1, "v": "x"},
          {"k": 2, "v": null}
        ]
        EOF
      reports.map(&.v?).should eq(["x", nil])
    end
  end
end
