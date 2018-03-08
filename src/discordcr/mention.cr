# Utility module for parsing mentions out of Discord messages
module Discord::Mention
  # A hash map of regex describing how mentions are parsed by type
  MENTION_REGEX = {
    User     => /<@!?(?<id>\d+)>/,
    Role     => /<@&(?<id>\d+)>/,
    Channel  => /<#(?<id>\d+)>/,
    Emoji    => /<(?<animated>a)?:(?<name>\w+):(?<id>\d+)>/,
    Everyone => /@everyone/,
    Here     => /@here/,
  }

  module SnowflakeMention
    getter size : Int32
    getter position : Int32
    getter id : UInt64

    def initialize(match : Regex::MatchData)
      @size = match.size
      @position = match.begin.not_nil!
      @id = match["id"].to_u64
    end
  end

  struct User
    include SnowflakeMention
  end

  struct Role
    include SnowflakeMention
  end

  struct Channel
    include SnowflakeMention
  end

  struct Emoji
    include SnowflakeMention

    getter name : String
    getter animated : Bool

    def initialize(match : Regex::MatchData)
      super
      @name = match["name"]
      @animated = !match["animated"]?.nil?
    end
  end

  module PresenceMention
    getter position : Int32

    def initialize(match : Regex::MatchData)
      @position = match.begin.not_nil!
    end
  end

  struct Everyone
    include PresenceMention

    def size
      9
    end
  end

  struct Here
    include PresenceMention

    def size
      5
    end
  end

  alias MentionType = User | Role | Channel | Emoji | Everyone | Here

  # Returns an array of mentions found in a string
  def self.parse(string : String)
    results = [] of MentionType
    MENTION_REGEX.each do |type, regexp|
      string.scan(regexp).each do |match|
        results << type.new(match)
      end
    end
    results
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
    MENTION_REGEX.each do |type, regexp|
      string.scan(regexp).each do |match|
        yield type.new(match)
      end
    end
  end
end
