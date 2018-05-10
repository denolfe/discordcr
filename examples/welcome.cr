# This simple example bot creates a message whenever a new user joins the server

require "../src/discordcr"

# Make sure to replace this fake data with actual data when running.
client = Discord::CachedClient.new(token: "Bot MjI5NDU5NjgxOTU1NjUyMzM3.Cpnz31.GQ7K9xwZtvC40y8MPY3eTqjEIXm", client_id: 229459681955652337_u64)
client.configure_caches do
  guild_cache Discord::MemoryCache
end

client.on_guild_member_add do |payload|
  # get the guild/server information
  guild = client.get_guild(payload.guild_id)

  client.create_message(guild.id, "Please welcome <@#{payload.user.id}> to #{guild.name}.")
end

client.run
