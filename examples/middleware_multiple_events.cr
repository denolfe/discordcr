require "../src/discordcr"

class TestMiddleware
  def call(payload : Discord::Message, context : Discord::Context)
    puts "MESSAGE_CREATE from #{payload.author.id}"
    yield
  end

  def call(payload : Discord::Gateway::GuildMemberUpdatePayload, context : Discord::Context, &block)
    puts "MEMBER_UPDATE from #{payload.user.id}"
  end
end

client = Discord::Client.new("Bot TOKEN")

client.on_message_create(TestMiddleware.new) do |payload, ctx|
  # Do something
end

# Pure middleware handler
client.on_guild_member_update(TestMiddleware.new)

# Plain handler, without middleware
client.on_message_create do |payload|
  puts "MESSAGE_CREATE (Regular handler) from #{payload.author.id}"
end

client.run
