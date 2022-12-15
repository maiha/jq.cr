require "./spec_helper"

module Mapping::QuotedKeys
  class API
    Jq.mapping({
      foo_bar_x: { String, %(."Foo Bar (X)")},
    })
  end

  it "works with keys containing spaces" do
    json = <<-EOF
      {
        "Foo Bar (Z)": "0",
        "Foo Bar (X)": "1"
      }
    EOF

    api = API.from_json(json)
    api.foo_bar_x.should eq("1")
  end

  # https://github.com/maiha/jq.cr/issues/3
  class Issue3
    Jq.mapping({
      time_series: { Hash(String, Hash(String, String)), %(."Time Series (X)")},
    })
  end

  it "works" do
    json = <<-EOF
      {
        "Time Series (X)": {
          "2022-12-14": {
            "1. key1": "val1"
          },
          "2022-12-13": {
            "1. key1": "val2"
          }
        }
      }
    EOF

    res = Issue3.from_json(json)
    res.time_series.should eq({"2022-12-14" => {"1. key1" => "val1"}, "2022-12-13" => {"1. key1" => "val2"}})
  end
end
