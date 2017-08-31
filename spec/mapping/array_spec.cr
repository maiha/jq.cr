require "./spec_helper"

module Mapping::RawArray
  class Status
    Jq.mapping({
      id: Int64,
      status: String,
    })
  end

  describe "Array(Foo).from_json" do
    it "should work" do
      json = <<-EOF
        [
          {"id": 1, "status": "OK"},
          {"id": 5, "status": "NG"}
        ]
      EOF
      array = Array(Status).from_json(json)
      array.map(&.id).should eq([1,5])
      array.map(&.status).should eq(["OK", "NG"])
    end

    it "should ignore extra fields" do
      json = <<-EOF
        [
          {"id": 1, "status": "OK", "xxx": 100},
          {"id": 5, "status": "NG"}
        ]
      EOF
      array = Array(Status).from_json(json)
      array.map(&.id).should eq([1,5])
      array.map(&.status).should eq(["OK", "NG"])
    end

    it "should work with lacked fields until used" do
      json = <<-EOF
        [
          {"id": 1, "status": "OK"},
          {"id": 5}
        ]
      EOF
      array = Array(Status).from_json(json)
      array.map(&.id).should eq([1,5])
      array[0].status.should eq("OK")
      array[1].status?.should eq(nil)

      expect_raises(Jq::NotFound) do
        array[1].status
      end
    end
  end
end
