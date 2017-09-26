require "./converters"

module Discord
  module REST
    # A response to the Get Gateway REST API call.
    struct GatewayResponse
      JSON.mapping(
        url: String
      )
    end

    # A response to the Get Guild Prune Count REST API call.
    struct PruneCountResponse
      JSON.mapping(
        pruned: UInt32
      )
    end

    # A response to the Get Guild Vanity URL REST API call.
    struct GuildVanityURLResponse
      JSON.mapping(
        code: String
      )
    end

    # A payload for modifying guild channel positions
    struct ModifyGuildChannelPositionPayload
      JSON.mapping(
        id: UInt64,
        position: Int32,
        parent_id: UInt64?,
        lock_permissions: Bool?
      )
    end

    # A payload for modifying guild role positions
    struct ModifyGuildRolePositionPayload
      JSON.mapping(
        id: UInt64,
        position: Int32
      )
    end
  end
end
