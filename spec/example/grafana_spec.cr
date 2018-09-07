require "./spec_helper"

module Example::Grafana
  QUERY = <<-EOF
  {
    "panelId":1,
    "range":{"from":"2016-09-02T13:32:09.981Z","to":"2016-09-02T14:17:34.306Z"},
    "rangeRaw":{"from":"2016-09-02T13:32:09.981Z","to":"2016-09-02T14:17:34.306Z"},
    "interval":"2s",
    "targets":[{"target":"cpu","refId":"A"},{"target":"mem","refId":"B"}],
    "format":"json",
    "maxDataPoints":1299
  }
  EOF

  class Request
    Jq.mapping({
      from:    {Time, ".range.from", "%FT%T.%LZ"},
      targets: {Array(String), ".targets[].target"},
      format:  String,
      max:     {Int64, ".maxDataPoints"},
    })
  end

  it "(functional way)" do
    jq = Jq.new(QUERY)
    jq[".range.from"].as_s.should eq("2016-09-02T13:32:09.981Z")
    jq[".targets[].target"].as_a.should eq(["cpu","mem"])
    jq[".format"].as_s.should eq("json")
    jq[".maxDataPoints"].as_i.should eq(1299)
    expect_raises Jq::NotFound do
      jq[".xxx"]
    end
    jq[".xxx"]?.should eq(nil)
  end

  it "(class mapping way)" do
    req = Request.from_json(QUERY)
    req.from.should eq(Time.utc(2016,9,2,13,32,9, nanosecond: 981_000_000))
    req.targets.should eq(["cpu","mem"])
    req.format.should eq("json")
    req.max.should eq(1299)

    req = Request.from_json("{}")
    req.max?.should eq(nil)
    expect_raises Jq::NotFound do
      req.max
    end
  end
end
