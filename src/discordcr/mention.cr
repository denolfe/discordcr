# Utility module for parsing mentions out of Discord messages
module Discord::Mention
  record User, position : Int32, size : Int32, id : UInt64

  record Role, position : Int32, size : Int32, id : UInt64

  record Channel, position : Int32, size : Int32, id : UInt64

  record Emoji, position : Int32, size : Int32, animated : Bool, name : String, id : UInt64

  record Everyone, position : Int32 do
    def size
      9
    end
  end

  record Here, position : Int32 do
    def size
      5
    end
  end

  alias MentionType = User | Role | Channel | Emoji | Everyone | Here

  # Returns an array of mentions found in a string
  def self.parse(string : String)
  end

  # Parses a string for mentions, yielding each one found
  #
  # ```
  # string = "Hello <@123>, welcome to <#456> <a:wave:789>"
  # Discord::Mention.parse(string) do |mention|
  #   case mention
  #   when Discord::Mention::User
  #     puts "#{mention.id} was mentioned"
  #   when Discord::Mention::Channel
  #     puts "channel #{mention.id} was mentioned"
  #   when Discord::Mention::Emoji
  #     puts "emoji #{mention.name} was used (animated? #{mention.animated})"
  #   end
  # end
  # ```
  def self.parse(string : String, &block : MentionType ->)
  end
end
