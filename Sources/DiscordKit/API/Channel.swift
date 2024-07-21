public protocol IdentifiableChannel: Identifiable, Codable {

    var client: Client { get }

    var id: Snowflake { get }
}

public protocol Channel: IdentifiableChannel, Codable {
    var type: ChannelType { get }
}

public protocol IdentifiableTextChannel: IdentifiableChannel {
    // If we want to do caching ie. channel.messages.fetch() && channel.messages.cache
    // var messages; MessageManager
}

extension IdentifiableTextChannel {
    public func send(_ content: String) {
        client.send(text: content, to: self)
    }

    public func getMessage(id: Snowflake) async throws -> Message {
        return try await client.getMessage(in: self, id: id)
    }

    public func getMessages(limit: Int = 10) async throws -> [Message] {
        return try await client.getMessages(in: self, limit: limit)
    }
}

public protocol TextChannel: IdentifiableTextChannel { }

struct TextChannelIdentifier: IdentifiableTextChannel {
    let client: Client

    let id: Snowflake

    func encode(to encoder: Encoder) throws {
        fatalError("Not Implemented")
    }

    /// Must be decoded from the single ID value.
    init(from decoder: Decoder) throws {

        guard let client = (decoder.userInfo[.contextManager] as? ContextManager)?.client else {
            fatalError("Could not get client from context manager")
        }

        self.client = client

        let container = try decoder.singleValueContainer()
        self.id = try container.decode(Snowflake.self)
    }
}

struct DMChannel: TextChannel {

    let client: Client

    let id: Snowflake

    public let type: ChannelType

    func encode(to encoder: Encoder) throws {
        fatalError("Not Implemented")
    }

    /// Decoded from an entire Message object.
    init(from decoder: Decoder) throws {
        guard let client = (decoder.userInfo[.contextManager] as? ContextManager)?.client else {
            fatalError("Could not get client from context manager")
        }

        self.client = client

        self.id = try decoder.container(keyedBy: CodingKeys.self).decode(Snowflake.self, forKey: .id)
        self.type = .dmChannel
    }

    enum CodingKeys: String, CodingKey {
        case id
    }

}

struct GuildChannel: TextChannel, IdentifiableTextChannel {

    let client: Client

    let id: Snowflake

    public let type: ChannelType

    // var guild_id: Snowflake

    func encode(to encoder: Encoder) throws {
        fatalError("Not Implemented")
    }

    init(from decoder: Decoder) throws {
        guard let client = (decoder.userInfo[.contextManager] as? ContextManager)?.client else {
            fatalError("Could not get client from context manager")
        }

        self.client = client

        self.id = try decoder.container(keyedBy: CodingKeys.self).decode(Snowflake.self, forKey: .id)
        self.type = .dmChannel
    }

    enum CodingKeys: String, CodingKey {
        case id
    }

}

public enum ChannelType: Decodable {
    case dmChannel
    case guildChannel

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let internalChannelTypeCode = try decoder.singleValueContainer().decode(Int.self)

        switch internalChannelTypeCode {
        case 0:
            self = .guildChannel
        case 1:
            self = .dmChannel
        default:
            fatalError("Unsupported channel type.")
        }
    }
}