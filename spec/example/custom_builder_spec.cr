require "./spec_helper"

module Example::CustomBuilder
  class Report
    Jq.mapping({
      id: Int32,
      count: Int32?,
    })

    def build_count(jq : Jq, hint : String)
      case jq.raw
      when "--", nil
        nil
      else
        jq.cast(Int32, hint)
      end
    end
  end

  describe "Example::CustomBuilder" do
    it "can accept both Int32 and String field" do
      reports = Array(Report).from_json <<-EOF
        [
          {"id": 1, "count": 10},
          {"id": 2, "count": "--"},
          {"id": 3, "count": null}
        ]
        EOF
      reports.map(&.count?).should eq([10, nil, nil])
    end
  end
end
