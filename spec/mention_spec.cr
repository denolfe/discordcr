require "./spec_helper"

describe Discord::Mention do
  string = "foo bar <@1> <@!2> <@&3> <#4> <:foo:5> <a:bar:6> @everyone @here"

  mentions = [
    Discord::Mention::User.new(8, 4, 1_u64),
    Discord::Mention::User.new(13, 5, 2_u64),
    Discord::Mention::Role.new(19, 5, 3_u64),
    Discord::Mention::Channel.new(25, 4, 4_u64),
    Discord::Mention::Emoji.new(30, 8, false, "foo", 5_u64),
    Discord::Mention::Emoji.new(39, 9, true, "bar", 6_u64),
    Discord::Mention::Everyone.new(49),
    Discord::Mention::Here.new(59),
  ]

  describe ".parse" do
    it "parses mentions" do
      parsed = Discord::Mention.parse(string)
      parsed.should eq mentions
    end

    it "accepts a block" do
      index = 0
      Discord::Mention.parse(string) do |mention|
        p mention
        # mention.should eq mentions[index]
        index += 1
      end
    end
  end
end
