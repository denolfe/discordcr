require "./spec_helper"

describe Discord::CDN do
  it "builds a custom emoji URL" do
    url = Discord::CDN.custom_emoji(1, :png, 16)
    url.should eq "https://cdn.discordapp.com/emojis/1.png?size=16"
  end

  it "builds a guild icon URL" do
    url = Discord::CDN.guild_icon(1, "hash", :png, 16)
    url.should eq "https://cdn.discordapp.com/icons/1/hash.png?size=16"
  end

  it "builds a guild splash URL" do
    url = Discord::CDN.guild_splash(1, "hash", :png, 16)
    url.should eq "https://cdn.discordapp.com/splashes/1/hash.png?size=16"
  end

  it "builds a default user avatar URL" do
    url = Discord::CDN.default_user_avatar("0001")
    url.should eq "https://cdn.discordapp.com/embed/avatars/1.png"

    url = Discord::CDN.default_user_avatar("0007")
    url.should eq "https://cdn.discordapp.com/embed/avatars/2.png"
  end

  describe "user_avatar" do
    it "builds a user avatar URL" do
      url = Discord::CDN.user_avatar(1, "hash", :png, 16)
      url.should eq "https://cdn.discordapp.com/avatars/1/hash.png?size=16"
    end

    context "without format" do
      it "detects an animated avatar" do
        url = Discord::CDN.user_avatar(1, "a_hash", 16)
        url.should eq "https://cdn.discordapp.com/avatars/1/a_hash.gif?size=16"
      end

      it "defaults to webp" do
        url = Discord::CDN.user_avatar(1, "hash", 16)
        url.should eq "https://cdn.discordapp.com/avatars/1/hash.webp?size=16"
      end
    end
  end

  it "builds an application icon URL" do
    url = Discord::CDN.application_icon(1, "hash", :png, 16)
    url.should eq "https://cdn.discordapp.com/app-icons/1/hash.png?size=16"
  end

  it "raises on an invalid size" do
    expect_raises(ArgumentError, "Size 17 is not between 16 and 2048 and a power of 2") do
      Discord::CDN.custom_emoji(1, :png, 17)
    end

    expect_raises(ArgumentError, "Size 0 is not between 16 and 2048 and a power of 2") do
      Discord::CDN.custom_emoji(1, :png, 0)
    end
  end
end

describe Discord::User do
  user_with_default_avatar = Discord::User.from_json <<-JSON
  {
    "id": "1",
    "username": "foo",
    "avatar": null,
    "discriminator": "0007"
  }
  JSON

  user_with_avatar = Discord::User.from_json <<-JSON
  {
    "id": "1",
    "username": "foo",
    "avatar": "hash",
    "discriminator": "0007"
  }
  JSON

  user_with_animated_avatar = Discord::User.from_json <<-JSON
  {
    "id": "1",
    "username": "foo",
    "avatar": "a_hash",
    "discriminator": "0007"
  }
  JSON

  describe "#avatar_url" do
    it "returns avatar URL with the given format and size" do
      user_with_avatar.avatar_url(:png, 16).should eq Discord::CDN.user_avatar(1, "hash", :png, 16)
    end

    it "returns default avatar URL with the given format and size" do
      user_with_default_avatar.avatar_url(:png, 16).should eq Discord::CDN.default_user_avatar("0007")
    end

    context "without format" do
      it "returns default avatar URL" do
        user_with_default_avatar.avatar_url.should eq Discord::CDN.default_user_avatar("0007")
      end

      it "returns avatar URL" do
        user_with_avatar.avatar_url.should eq Discord::CDN.user_avatar(1, "hash")
      end

      it "returns animated avatar URL" do
        user_with_animated_avatar.avatar_url.should eq Discord::CDN.user_avatar(1, "a_hash")
      end
    end
  end
end

describe Discord::Guild do
  guild_with_icon_and_splash = Discord::Guild.from_json <<-JSON
  {
    "id": "1",
    "name": "name",
    "icon": "hash",
    "splash": "hash",
    "owner_id": "2",
    "region": "region",
    "verification_level": 1,
    "roles": [],
    "emojis": [],
    "features": [],
    "default_message_notifications": 1,
    "explicit_content_filter": 1
  }
  JSON

  it "#icon_url" do
    guild = guild_with_icon_and_splash
    guild.icon_url(:png, 16).should eq Discord::CDN.guild_icon(guild.id, guild.icon.not_nil!, :png, 16)
  end

  it "#splash_url" do
    guild = guild_with_icon_and_splash
    guild.splash_url(:png, 16).should eq Discord::CDN.guild_splash(guild.id, guild.splash.not_nil!, :png, 16)
  end
end
