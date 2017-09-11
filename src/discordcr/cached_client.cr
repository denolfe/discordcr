require "./client"

module Discord
  # `CachedClient` is an extension of `Client` that adds customizable caches to track state.
  class CachedClient < Client
    getter! cache_set : Cache::CacheSet

    def initialize(token : String, client_id : UInt64,
                   shard : Gateway::ShardKey? = nil,
                   large_threshold : Int32 = 100,
                   compress : Bool = false,
                   properties : Gateway::IdentifyProperties = DEFAULT_PROPERTIES)
      super(token, client_id, shard, large_threshold, compress, properties)
      @cache_set = Cache::CacheSet.new(self)
      init_handlers
    end

    # Registers event handlers on this client to maintain cached data
    private def init_handlers
      on_guild_create do |payload|
        if cache = cache_set.guild
          guild = Discord::Guild.new(payload)
          cache.cache(guild)
        end

        if cache = cache_set.channel
          payload.channels.each do |channel|
            channel.guild_id = payload.id
            cache.cache(channel)
          end
        end

        # TODO: In the other handlers, I check for a cache first before iterating.
        # However, here, I opt to always iterate (once) over both. Maybe I should do otherwise.
        # It's extremely likely someone at *least* has a guild_member cache.
        payload.members.each do |member|
          if cache = cache_set.member
            cache.cache({payload.id, member.id}, member)
          end

          if user_cache = cache_set.user
            user_cache.cache(member.user)
          end
        end

        if cache = cache_set.role
          payload.roles.each do |role|
            cache.cache({payload.id, role.id}, role)
          end
        end

        # TODO: Emoji
        # TODO: Presence
      end

      on_guild_update do |payload|
        if cache = cache_set.guild
          cache.cache(payload)
        end
      end

      on_guild_delete do |payload|
        if cache = cache_set.guild
          cache.remove(payload.id)
        end
      end

      on_guild_member_add do |payload|
        if cache = cache_set.guild_member
          member = Discord::GuildMember.new(payload)
          cache.cache({payload.id, member.id}, member)
        end
      end

      on_guild_members_chunk do |payload|
        if cache = cache_set.guild_member
          payload.members.each do |member|
            cache.cache({payload.id, member.id}, member)
          end
        end
      end

      on_guild_member_update do |payload|
        if cache = cache_set.guild_member
          if existing_member = cache.resolve?({payload.guild_id, payload.user.id})
            updated_member = GuildMember.new(exisiting_member, payload.roles)
            cache.cache({payload.guild_id, payload.user.id}, updated_member)
          else
            member = GuildMember.new(payload)
            cache.cache({payload.guild_id, payload.user.id}, member)
          end
        end
      end

      on_guild_member_remove do |payload|
        if cache = cache_set.guild_member
          cache.remove({payload.guild_id, payload.user.id})
        end
      end

      on_channel_create do |payload|
      end

      on_channel_update do |payload|
      end

      on_channel_delete do |payload|
      end

      on_message_create do |payload|
      end

      on_message_update do |payload|
      end

      on_message_delete do |payload|
      end
    end

    macro cached_route(method, key_type, resource_type)
      {% if key_type.is_a?(TupleLiteral) %}
        {{index = 0}}
        {{typed_args = key_type.map { |key| index = index + 1; "arg#{index} : #{key}" }}}

        {{index = 0}}
        {{args = key_type.map { |key| index = index + 1; "arg#{index}" }}}
        # See `REST#{{method}}`
        def {{method}}({{typed_args.map(&.id).splat}})
          if cache = cache_set[{{resource_type}}]
            object = cache.resolve?({{args.map(&.id)}})
            object ||= cache.cache(
              {{args.map(&.id)}},
              super({{args.map(&.id).splat}})
            )
          else
            super({{args.map(&.id).splat}})
          end
        end
      {% else %}
        # See `REST#{{method}}`
        def {{method}}(id : {{key_type}})
          if cache = cache_set[{{resource_type}}]
            object = cache.resolve?(id)
            object ||= cache.cache super(id)
          else
            super(id)
          end
        end
      {% end %}
    end

    cached_route get_guild, UInt64, Guild

    cached_route get_guild_member, {UInt64, UInt64}, GuildMember

    cached_route get_guild_channel, UInt64, Channel

    # See `REST#get_guild_roles`
    def get_guild_roles(id : UInt64)
      if cache = cache_set.role
        roles = cache.resolve(id)
        return roles unless roles.empty?
        new_roles = super(id)
        new_roles.map { |role| cache.cache({id, role.id}, role) }
      else
        super(id)
      end
    end
  end
end
