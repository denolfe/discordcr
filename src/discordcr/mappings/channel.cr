require "./converters"

module Discord
  enum MessageType : UInt8
    Default              = 0
    RecipientAdd         = 1
    RecipientRemove      = 2
    Call                 = 3
    ChannelNameChange    = 4
    ChannelIconChange    = 5
    ChannelPinnedMessage = 6
    GuildMemberJoin      = 7
  end

  struct Message
    include JSON::Serializable

    getter type : MessageType

    getter content : String

    getter id : Snowflake

    getter channel_id : Snowflake

    getter author : User

    @[JSON::Field(converter: Discord::TimestampConverter)]
    getter timestamp : Time

    getter tts : Bool

    getter mention_everyone : Bool

    getter mentions : Array(User)

    getter mention_roles : Array(Snowflake)

    getter attachments : Array(Attachment)

    getter embeds : Array(Embed)

    getter pinned : Bool?

    getter reactions : Array(Reaction)?

    getter activity : Activity?
  end

  enum ActivityType : UInt8
    Join        = 1
    Spectate    = 2
    Listen      = 3
    JoinRequest = 5
  end

  struct Activity
    include JSON::Serializable

    getter type : ActivityType

    getter party_id : String?
  end

  enum ChannelType : UInt8
    GuildText = 0
    DM        = 1
    Voice     = 2
    GroupDM   = 3
  end

  struct Channel
    include JSON::Serializable

    getter id : Snowflake

    getter type : ChannelType

    getter guild_id : Snowflake?

    getter name : String?

    getter permission_overwrites : Array(Overwrite)?

    getter topic : String?

    getter last_message_id : Snowflake?

    getter bitrate : UInt32?

    getter user_limit : UInt32?

    getter recipients : Array(User)?

    getter nsfw : Bool?

    getter icon : Bool?

    getter owner_id : Snowflake?

    getter application_id : Snowflake?

    getter position : Int32?

    getter parent_id : Snowflake?

    # :nodoc:
    def initialize(private_channel : PrivateChannel)
      @id = private_channel.id
      @type = private_channel.type
      @recipients = private_channel.recipients
      @last_message_id = private_channel.last_message_id
    end
  end

  struct PrivateChannel
    include JSON::Serializable

    getter id : Snowflake

    getter type : ChannelType

    getter recipients : Array(User)

    getter last_message_id : Snowflake?
  end

  struct Overwrite
    include JSON::Serializable

    getter id : Snowflake

    getter type : String

    getter allow : Permissions

    getter deny : Permissions
  end

  struct Reaction
    include JSON::Serializable

    getter emoji : ReactionEmoji

    getter count : UInt32

    getter me : Bool
  end

  struct ReactionEmoji
    JSON.mapping(
      id: Snowflake?,
      name: String
    )
  end

  struct Embed
    def initialize(@title : String? = nil, @type : String = "rich",
                   @description : String? = nil, @url : String? = nil,
                   @timestamp : Time? = nil, @colour : UInt32? = nil,
                   @footer : EmbedFooter? = nil, @image : EmbedImage? = nil,
                   @thumbnail : EmbedThumbnail? = nil, @author : EmbedAuthor? = nil,
                   @fields : Array(EmbedField)? = nil)
    end

    JSON.mapping(
      title: String?,
      type: String,
      description: String?,
      url: String?,
      timestamp: {type: Time?, converter: MaybeTimestampConverter},
      colour: {type: UInt32?, key: "color"},
      footer: EmbedFooter?,
      image: EmbedImage?,
      thumbnail: EmbedThumbnail?,
      video: EmbedVideo?,
      provider: EmbedProvider?,
      author: EmbedAuthor?,
      fields: Array(EmbedField)?
    )

    {% unless flag?(:correct_english) %}
      def color
        colour
      end
    {% end %}
  end

  struct EmbedThumbnail
    def initialize(@url : String)
    end

    JSON.mapping(
      url: String,
      proxy_url: String?,
      height: UInt32?,
      width: UInt32?
    )
  end

  struct EmbedVideo
    JSON.mapping(
      url: String,
      height: UInt32,
      width: UInt32
    )
  end

  struct EmbedImage
    def initialize(@url : String)
    end

    JSON.mapping(
      url: String,
      proxy_url: String?,
      height: UInt32?,
      width: UInt32?
    )
  end

  struct EmbedProvider
    JSON.mapping(
      name: String,
      url: String?
    )
  end

  struct EmbedAuthor
    def initialize(@name : String? = nil, @url : String? = nil, @icon_url : String? = nil)
    end

    JSON.mapping(
      name: String?,
      url: String?,
      icon_url: String?,
      proxy_icon_url: String?
    )
  end

  struct EmbedFooter
    def initialize(@text : String? = nil, @icon_url : String? = nil)
    end

    JSON.mapping(
      text: String?,
      icon_url: String?,
      proxy_icon_url: String?
    )
  end

  struct EmbedField
    def initialize(@name : String, @value : String, @inline : Bool = false)
    end

    JSON.mapping(
      name: String,
      value: String,
      inline: Bool
    )
  end

  struct Attachment
    JSON.mapping(
      id: Snowflake,
      filename: String,
      size: UInt32,
      url: String,
      proxy_url: String,
      height: UInt32?,
      width: UInt32?
    )
  end
end
