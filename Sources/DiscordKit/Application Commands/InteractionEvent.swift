struct InteractionEvent: Decodable {
    let id: Snowflake
    let token: String

    let type: InteractionType
    let data: InteractionData

    enum InteractionType: Int, Decodable {
        case ping = 1
        case applicationCommand = 2
        case messageComponent = 3 // not sure what this one is
        case applicationCommandAutocomplete = 4
        case modalSubmit = 5
    }

    enum CodingKeys: String, CodingKey {
        case id, token, type, data
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