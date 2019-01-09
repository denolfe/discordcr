require "./spec_helper"

module OptionConverter(T)
  def self.from_json(parser : JSON::PullParser)
    parser.read_string_or_null || T.null_value
  end
end

struct User
  # include JSON::Serializable

  # For JSON::Serializable:
  # @[JSON::Field(presence: true, converter: OptionConverter(User::Avatar))]
  # @avatar : String | Avatar | Nil = nil

  # @[JSON::Field(ignore: true)]
  # @avatar_present : Bool

  enum Avatar
    Default

    def self.null_value
      Default
    end
  end

  JSON.mapping(avatar: {type: String | Avatar | Nil, presence: true, converter: OptionConverter(User::Avatar)})

  def avatar
    if @avatar_present && @avatar.nil?
      Avatar::Default
    else
      @avatar # (String)
    end
  end
end

describe User do
  it "returns default when key present and null" do
    user = User.from_json(%({"avatar":null}))
    user.avatar.should eq User::Avatar::Default
  end

  it "returns a present avatar string" do
    user = User.from_json(%({"avatar":"avatar"}))
    user.avatar.should eq "avatar"
  end

  it "returns unknown on absence" do
    user = User.from_json(%({}))
    user.avatar.should eq nil
  end
end

describe Discord::Cache do
  it "BUG: client doesn't update a removed avatar" do
    client = Discord::Client.new("", logger: Logger.new(STDOUT, level: Logger::Severity::DEBUG))
    cache = Discord::Cache.new(client)
    client.cache = cache

    # Channel that waits for the client to handle the injected payload:
    channel = Channel(Nil).new
    client.on_presence_update { channel.send(nil) }

    # Initial presence update, that contains all user information, with an avatar set:
    presence_a = Discord::WebSocket::Packet.new(0, 0, IO::Memory.new(<<-JSON), "PRESENCE_UPDATE")
    {
      "user": {
        "id": "1",
        "username": "z64",
        "discriminator": "1337",
        "avatar": "avatar"
      },
      "roles": [],
      "guild_id": "2",
      "status": "online"
    }
    JSON

    client.inject(presence_a)
    channel.receive
    cache.resolve_member(2, 1).user.avatar.should eq "avatar"

    # Subsequent presence update, of a user removing their avatar:
    presence_b = Discord::WebSocket::Packet.new(0, 0, IO::Memory.new(<<-JSON), "PRESENCE_UPDATE")
    {
      "user": {
        "id": "1",
        "username": "z64",
        "discriminator": "1337",
        "avatar": null
      },
      "roles": [],
      "guild_id": "2",
      "status": "offline"
    }
    JSON

    client.inject(presence_b)
    channel.receive
    cache.resolve_member(2, 1).user.avatar.should eq "avatar"
  end
end
