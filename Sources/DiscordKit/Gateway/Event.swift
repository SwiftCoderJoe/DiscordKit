enum Event {
    case ready(ReadyData)
    case message(Message)
    case unknown(String)

    struct ReadyData: Codable {
        let user: DiscordUser

        enum CodingKeys: String, CodingKey {
            case user
        }
    }
}

extension Event: Codable {
    func encode(to encoder: Encoder) throws {
        fatalError("Encoding events not implemented. Should probably be decodable")
    }

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
        default:
            self = .unknown(eventName)
        }
    }
}
