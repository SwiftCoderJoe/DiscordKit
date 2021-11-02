enum Event {
    case ready(ReadyData)
    case message(Message)
    case unknown(Decoder?)

    struct ReadyData: Codable {
        let user: DiscordUser

        enum CodingKeys: String, CodingKey {
            case user = "user"
        }
    }
}

enum SubscribableEvent: String, Hashable {
    case ready = "READY"
    case message = "MESSAGE_CREATE"
    case unknown = "unknown"
}

extension Event: Codable {
    enum Events: String, Codable {
        case ready = "READY"
        case message = "MESSAGE_CREATE"
        case unknown = "unknown"
    }

    var type: Events {
        switch (self) {
        case .ready:
            return .ready
        case .message:
            return .message
        case .unknown:
            return .unknown
        }
    }

    var subscribable: SubscribableEvent {
        return SubscribableEvent(rawValue: self.type.rawValue) ?? .unknown
    }

    func encode(to encoder: Encoder) throws {
        print("ENCODING EVENTS NOT IMPLEMENTED")
        var container = encoder.singleValueContainer()
        try container.encode(false)
    }

    init(from decoder: Decoder) throws {
        guard let eventType = (decoder.userInfo[.contextManager] as? ContextManager)?.eventName else {
            self = .unknown(decoder)
            return
        }
        let container = try decoder.singleValueContainer()

        switch eventType {
        case .ready:
            let specificData = try container.decode(ReadyData.self)
            self = .ready(specificData)
        case .message:
            let specificData = try container.decode(Message.self)
            self = .message(specificData)
        case .unknown:
            // Never happens
            self = .unknown(nil)
        }
    }
}
