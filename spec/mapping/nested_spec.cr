require "./spec_helper"

module Mapping::Nested
  class Group
    Jq.mapping({
      name: String
    })
  end

  class UserGroup
    Jq.mapping({
      name: String,
      group: Group,
    })
  end

  it "nested mapping should work" do
    json = <<-EOF
      {
        "name":"maiha",
        "group":{"name":"admin"}
      }
    EOF

    user = UserGroup.from_json(json)
    user.name.should eq("maiha")
    user.group.name.should eq("admin")
  end

  class UserGroups
    Jq.mapping({
      name: String,
      groups: {Array(Group), ".groups"},
    })
  end

  it "nested mapping should work" do
    json = <<-EOF
      {
        "name":"maiha",
        "groups":[
          {"name":"admin"},
          {"name":"users"}
        ]
      }
    EOF

    user = UserGroups.from_json(json)
    user.name.should eq("maiha")
    user.groups.map(&.name).should eq(["admin", "users"])
  end
end
