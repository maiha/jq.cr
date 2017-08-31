require "./spec_helper"

module Example::Facebook::AdImages
  # account.adimages(fields: ["name", "status", "creatives"])
  STR = <<-EOF
  [
    {
      "name": "abc",
      "status": "ACTIVE",
      "creatives": ["123456","789012"]
    },
    {
      "name": "xyz",
      "status": "ACTIVE"
    }
  ]
  EOF

  class AdImage
    Jq.mapping({
      name:      String,
      status:    String,
      creatives: {Array(String), ".creatives"}
    })
  end

  describe "Example::Facebook::AdImages" do
    it "works with array field" do
      images = Array(AdImage).from_json(STR)
      images[0].creatives.should eq(["123456","789012"])
    end

    it "return empty array when array field is missing" do
      images = Array(AdImage).from_json(STR)
      images[1].creatives.should eq(Array(String).new)
    end
  end
end
