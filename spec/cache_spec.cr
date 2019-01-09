require "./spec_helper"

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
