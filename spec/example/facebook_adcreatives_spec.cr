require "./spec_helper"

module Example::Facebook::AdCreatives
  # account.adcreatives(fields: %w( title object_story_id object_story_spec ))
  STR = <<-EOF
  [
    {
      "title": "abc",
      "object_story_spec": {
        "page_id": "012345...",
        "link_data": {
          "link": "http://example.com/",
          "message": "advertise message",
          "name": "title",
          "attachment_style": "link",
          "image_hash": "c9e4c9...",
          "call_to_action": {
            "type": "LEARN_MORE"
          },
          "child_attachments": [
            {
              "link": "http://example.com/1",
              "image_hash": "405bf...",
              "name": "title of carousel1",
              "call_to_action": {
                "type": "LEARN_MORE"
              }
            },
            {
              "link": "http://example.com/2",
              "image_hash": "9cef4...",
              "name": "title of carousel2",
              "call_to_action": {
                "type": "LEARN_MORE"
              }
            }
          ]
        }
      }
    }
  ]
  EOF
  
  class Attachment
    Jq.mapping({
      link:        String,
      name:        String,
    })
  end

  class LinkData
    Jq.mapping({
      link:        String,
      message:     String,
      name:        String,
      attachments: {Array(Attachment), ".child_attachments"},
    })
  end

  class AdCreative
    Jq.mapping({
      title:     String,
      link_data: {LinkData, ".object_story_spec.link_data"},
    })
  end

  describe "Example::Facebook::AdCreatives" do
    it "works" do
      creatives = Array(AdCreative).from_json(STR)
      link = creatives[0].link_data
      link.attachments.map(&.link).should eq(["http://example.com/1","http://example.com/2"])
    end
  end
end
