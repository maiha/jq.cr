require "./spec_helper"

module Mapping::TimeFormatSpec
  EXPECTED   = %({"from":"2016-09-02T13:32:09.981Z"})
  UNEXPECTED = %({"from":"2016-09-02 13:32:09.981"})

  class Request
    Jq.mapping({
      from: {Time, ".from", "%FT%T.%LZ"},
    })
  end

  it "accepts format arg when type is Time" do
    Request.from_json(EXPECTED).from.should eq(Time.new(2016,9,2,13,32,9,981))
  end

  it "raises when unexpected data has come" do
    expect_raises Jq::ParseError do
      Request.from_json(UNEXPECTED).from
    end
  end
end
