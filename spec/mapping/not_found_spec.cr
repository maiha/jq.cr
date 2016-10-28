require "./spec_helper"

module MappingNotFoundSpec
  class User
    Jq.mapping({
      name: String
    })
  end

  class UserWithDefault
    Jq.mapping({
      name: String
    })

    protected def default_name
      "no name"
    end
  end

  describe "Jq.mapping:NotFound" do
    it "raise error in default" do
      expect_raises(Jq::NotFound) {
        User.from_json("{}").name
      }
    end

    it "respect default method" do
      UserWithDefault.from_json("{}").name.should eq("no name")
    end
  end
end
