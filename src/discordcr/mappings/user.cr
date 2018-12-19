require "./converters"

module Discord
  struct User
    @[Flags]
    enum Flags
      HypeSquadEvents = 1 << 2
      HouseBravery    = 1 << 6
      HouseBrilliance = 1 << 7
      HouseBalance    = 1 << 8

      def self.new(parser : JSON::PullParser)
        new(parser.read_int.to_i32)
      end
    end

    enum PremiumType
      NitroClassic = 1
      Nitro        = 2
    end

    # :nodoc:
    def initialize(partial : PartialUser)
      @username = partial.username.not_nil!
      @id = partial.id
      @discriminator = partial.discriminator.not_nil!
      @avatar = partial.avatar
      @email = partial.email
      @bot = partial.bot
    end

    JSON.mapping(
      username: String,
      id: Snowflake,
      discriminator: String,
      avatar: String?,
      email: String?,
      bot: Bool?,
      mfa_enabled: Bool?,
      verified: Bool?,
      member: PartialGuildMember?,
      flags: Flags?,
      premium_type: PremiumType?
    )

    # Produces a CDN URL to this user's avatar in the given `size`.
    # If the user has an avatar a WebP will be returned, or a GIF
    # if the avatar is animated. If the user has no avatar, a default
    # avatar URL is returned.
    def avatar_url(size : Int32 = 128)
      if avatar = @avatar
        CDN.user_avatar(id, avatar, size)
      else
        CDN.default_user_avatar(discriminator)
      end
    end

    # Produces a CDN URL to this user's avatar, in the given `format` and
    # `size`. If the user has no avatar, a default avatar URL is returned.
    def avatar_url(format : CDN::UserAvatarFormat, size : Int32 = 128)
      if avatar = @avatar
        CDN.user_avatar(id, avatar, format, size)
      else
        CDN.default_user_avatar(discriminator)
      end
    end

    # Produces a string to mention this user in a message
    def mention
      "<@#{id}>"
    end
  end

  struct PartialUser
    JSON.mapping(
      username: String?,
      id: Snowflake,
      discriminator: String?,
      avatar: String?,
      email: String?,
      bot: Bool?
    )

    def full? : Bool
      !@username.nil? && !@discriminator.nil? && !@avatar.nil?
    end
  end

  struct UserGuild
    JSON.mapping(
      id: Snowflake,
      name: String,
      icon: String?,
      owner: Bool,
      permissions: Permissions
    )
  end

  struct Connection
    JSON.mapping(
      id: Snowflake,
      name: String,
      type: String,
      revoked: Bool
    )
  end
end
