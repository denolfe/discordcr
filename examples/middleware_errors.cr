require "../src/discordcr"

# Because `yield` nests for each middleware in the chain, you can rescue
# from any exception that happens later in the chain and handle it. Here we
# raise an Exception in the trailing block, it is caught by ErrorCatcher
# middleware, which responds with a heartfelt apology and passes the error up.

class ErrorCatcher
  def call(payload, context)
    yield
  rescue ex
    channel_id = payload.channel_id
    context[Discord::Client].create_message(channel_id, "Sorry, an error occurred: #{ex}")
    raise ex
  end
end

# A basic, customizable prefix check
class Prefix
  def initialize(@prefix : String)
  end

  def call(payload : Discord::Message, context : Discord::Context)
    # If the message doesn't start with our prefix, we ignore the message.
    yield if payload.content.starts_with?(@prefix)
  end
end

client = Discord::Client.new("Bot TOKEN")

client.on_message_create(Prefix.new("!test"), ErrorCatcher.new) do |context|
  raise "Woops!"
end

client.run
