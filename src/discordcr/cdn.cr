# This module contains methods for building URLs to resources on Discord's CDN
# for things like guild icons and avatars.
#
# [API Documentation for image formatting](https://discordapp.com/developers/docs/reference#image-formatting)
module Discord::CDN
  extend self

  # Base CDN URL
  BASE_URL = "https://cdn.discordapp.com"

  enum CustomEmojiFormat
    PNG
    GIF

    def to_s(io : IO)
      io << to_s.downcase
    end
  end

  enum GuildIconFormat
    PNG
    JPEG
    WebP

    def to_s(io : IO)
      io << to_s.downcase
    end
  end

  enum GuildSplashFormat
    PNG
    JPEG
    WebP

    def to_s(io : IO)
      io << to_s.downcase
    end
  end

  enum UserAvatarFormat
    PNG
    JPEG
    WebP
    GIF

    def to_s(io : IO)
      io << to_s.downcase
    end
  end

  enum ApplicationIconFormat
    PNG
    JPEG
    WebP
    GIF

    def to_s(io : IO)
      io << to_s.downcase
    end
  end

  private def check_size(value : Int32)
    in_range = (16..2048).includes?(value)
    power_of_two = (value > 0) && ((value & (value - 1)) == 0)
    unless in_range && power_of_two
      raise ArgumentError.new("Size #{value} is not between 16 and 2048 and a power of 2")
    end
  end

  def custom_emoji(id : UInt64 | Snowflake,
                   format : CustomEmojiFormat = CustomEmojiFormat::PNG,
                   size : Int32 = 128)
    check_size(size)
    "#{BASE_URL}/emojis/#{id}.#{format}?size=#{size}"
  end

  def guild_icon(id : UInt64 | Snowflake, icon : String,
                 format : GuildIconFormat = GuildIconFormat::WebP,
                 size : Int32 = 128)
    check_size(size)
    "#{BASE_URL}/icons/#{id}/#{icon}.#{format}?size=#{size}"
  end

  def guild_splash(id : UInt64 | Snowflake, splash : String,
                   format : GuildSplashFormat = GuildSplashFormat::WebP,
                   size : Int32 = 128)
    check_size(size)
    "#{BASE_URL}/splashes/#{id}/#{splash}.#{format}?size=#{size}"
  end

  def default_user_avatar(user_discriminator : String)
    index = user_discriminator.to_i % 5
    "#{BASE_URL}/embed/avatars/#{index}.png"
  end

  def user_avatar(id : UInt64 | Snowflake, avatar : String, size : Int32 = 128)
    if avatar.starts_with?("a_")
      user_avatar(id, avatar, UserAvatarFormat::GIF, size)
    else
      user_avatar(id, avatar, UserAvatarFormat::WebP, size)
    end
  end

  def user_avatar(id : UInt64 | Snowflake, avatar : String,
                  format : UserAvatarFormat, size : Int32 = 128)
    check_size(size)
    "#{BASE_URL}/avatars/#{id}/#{avatar}.#{format}?size=#{size}"
  end

  def application_icon(id : UInt64 | Snowflake, icon : String,
                       format : ApplicationIconFormat = ApplicationIconFormat::WebP,
                       size : Int32 = 128)
    check_size(size)
    "#{BASE_URL}/app-icons/#{id}/#{icon}.#{format}?size=#{size}"
  end
end
