require "./spec_helper"

describe Discord::Mention do
  string = "foo bar <@123> <@!123> <@&123> <#123> <:foo:123> <a:bar:123> @everyone @here"

  describe ".parse" do
    it "parses mentions" do
      parsed = Discord::Mention.parse(string)

      parsed.size.should eq 8
      parsed.each do |mention|
        case mention
        when Discord::Mention::SnowflakeMention
          mention.id.should eq 123
        when Discord::Mention::Emoji
          mention.id.should eq 123

          if mention.name == "foo"
            mention.animated.should eq false
          elsif mention.name == "bar"
            mention.animated.should eq true
          end
        end
      end

      parsed[6].should be_a Discord::Mention::Everyone
      parsed[7].should be_a Discord::Mention::Here
    end

    it "accepts a block" do
      total = 0
      Discord::Mention.parse(string) do |mention|
        total += 1
      end
      total.should eq 8
    end
  end
end
