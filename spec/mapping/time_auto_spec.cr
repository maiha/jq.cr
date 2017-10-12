require "./spec_helper"

private macro utc(*args)
  Time.new({{*args}}, kind: Time::Kind::Utc)
end

module Mapping::TimeAutoSpec
  class Request
    Jq.mapping({
      time: Time,
      auto: {Time, ".time"},
    })
  end

  context "2000-01-02T03:04:05.678Z" do
    it "works" do
      req = Request.from_json(%({"time":"2000-01-02T03:04:05.678Z"}))
#      req.auto.should eq(utc(2000,1,2,3,4,5))
    end
  end
end
