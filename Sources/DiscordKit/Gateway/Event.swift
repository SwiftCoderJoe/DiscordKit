enum Event {
    case ready(ReadyData)
    case message(Message)
    case interaction(InteractionEvent)
    case unknown(String)

    struct ReadyData: Codable {
        let user: DiscordUser
        let application: ApplicationData

        struct ApplicationData: Codable {
            let id: Snowflake
        }

        enum CodingKeys: String, CodingKey {
            case user, application
        }
    }
}

extension Event: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WSPayload.CodingKeys.self)
        let eventName = try container.decode(String.self, forKey: .eventName)

        switch eventName {
        case "READY":
            let specificData = try container.decode(ReadyData.self, forKey: .data)
            self = .ready(specificData)
        case "MESSAGE_CREATE":
            let specificData = try container.decode(Message.self, forKey: .data)
            self = .message(specificData)
        case "INTERACTION_CREATE":
            let specificData = try container.decode(InteractionEvent.self, forKey: .data)
            self = .interaction(specificData)
        default:
            self = .unknown(eventName)
        }
    }
}
