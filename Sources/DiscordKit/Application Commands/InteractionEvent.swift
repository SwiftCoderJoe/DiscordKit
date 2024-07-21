struct InteractionEvent: Decodable {
    let id: Snowflake
    let token: String

    let type: InteractionType
    let data: InteractionData


    // TODO: Some way to make this a concrete type?
    let channel: any TextChannel
    let guildID: Snowflake?

    enum InteractionType: Int, Decodable {
        case ping = 1
        case applicationCommand = 2
        case messageComponent = 3 // not sure what this one is
        case applicationCommandAutocomplete = 4
        case modalSubmit = 5
    }

    enum CodingKeys: String, CodingKey {
        case id, token, type, data
        case guildID = "guild_id"
        case channel = "channel"
    }

    enum InteractionData: Decodable {
        case applicationCommand(ApplicationCommandData)
        // case messageComponent(MessageComponentData) // Again, no idea what this one is for atm

        struct ApplicationCommandData: Decodable {
            let commandID: Snowflake

            // TODO: implement options in commands

            // We ignore the rest of the params here because they seem unnecessary.
            // https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-application-command-data-structure
        
            enum CodingKeys: String, CodingKey {
                case commandID = "id"
            }
        }
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = try container.decode(InteractionType.self, forKey: .type)
        id = try container.decode(Snowflake.self, forKey: .id)
        token = try container.decode(String.self, forKey: .token)

        // TODO: I don't like that I have to decode the type here and then do a long switch... 
        // seems like there ought to be a better way to do this.
        let channelType = try container
            .nestedContainer(keyedBy: ChannelType.CodingKeys.self, forKey: .channel)
            .decode(ChannelType.self, forKey: .type)

        switch channelType {
        case .dmChannel:
            channel = try container.decode(DMChannel.self, forKey: .channel)
        case .guildChannel:
            channel = try container.decode(GuildChannel.self, forKey: .channel)
        }
        
        guildID = try container.decode(Snowflake.self, forKey: .guildID)

        switch type {
        case .applicationCommand:
            fallthrough
        case .applicationCommandAutocomplete:
            let specificData = try container.decode(InteractionData.ApplicationCommandData.self, forKey: .data)
            data = .applicationCommand(specificData)
        default:
            fatalError("Unimplemented decode")
        }
    }
}