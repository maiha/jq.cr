require "./spec_helper"

module MappingSpec
  JSON_STRING = <<-EOF
   {
   "title":"Example Schema",
   "type":"object",
   "properties":{
      "firstName":{
         "type":"string"
      },
      "lastName":{
         "type":"string"
      },
      "age":{
         "description":"Age in years",
         "type":"integer",
         "minimum":0
      }
   },
   "required":[
      "firstName",
      "lastName"
   ]
   }
   EOF

  class ValidSchema
    Jq.mapping({
      title: {String, ".title"},
      age:   {Int64, ".properties.age.minimum"},
    })
  end

  class PathNodeNotFound
    Jq.mapping({
      title: {String, ".title"},
      age:   {Int64, ".properties.foo"},
    })
  end

  class ClassMismatch
    Jq.mapping({
      title: {Int64, ".title"},
    })
  end

  class NotLeaf
    Jq.mapping({
      age: {Int64, ".properties.age"},
    })
  end

  class TypeOnly
    Jq.mapping({
      title: String,
    })
  end

  describe "Jq.mapping(from_json)" do
    it "provides attributes via valid schema" do
      s = ValidSchema.from_json(JSON_STRING)
      s.title.should eq("Example Schema")
      s.age.should eq(0)
    end

    it "raises when path node is not found" do
      expect_raises Jq::ParseException, "`.properties.foo' Missing hash key:" do
        PathNodeNotFound.from_json(JSON_STRING)
      end
    end

    it "raises when attr's class is not match" do
      expect_raises Jq::ParseException, "`.title' expected Int64, but got String" do
        ClassMismatch.from_json(JSON_STRING)
      end

      expect_raises Jq::ParseException, "`.properties.age' expected Int64, but got Hash" do
        NotLeaf.from_json(JSON_STRING)
      end
    end

    it "uses '.key' for the path when path is missing" do
      s = TypeOnly.from_json(JSON_STRING)
      s.title.should eq("Example Schema")
    end
  end

  describe "(to_json)" do
    # NOTE: from_json could not parse json created by to_json
    it "provides simple json" do
      s = MappingSpec::ValidSchema.from_json(MappingSpec::JSON_STRING)
      s.to_json.should eq(%({"title":"Example Schema","age":0}))
    end
  end
end
