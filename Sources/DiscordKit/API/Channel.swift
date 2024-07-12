public protocol Channel: Codable {

    var client: Client { get }

    var id: Snowflake { get }

    var type: ChannelType { get }

}

public protocol TextChannel: Channel {
    
}

extension TextChannel {
    public func send(_ content: String) {
        client.send(text: content, to: self)
    }
}

struct DMChannel: TextChannel {

    var client: Client

    public var id: Snowflake

    var type: ChannelType

    func encode(to encoder: Encoder) throws {
        fatalError("Not Implemented")
    }

    init(from decoder: Decoder) throws {

        guard let client = (decoder.userInfo[.contextManager] as? ContextManager)?.client else {
            fatalError("Could not get client from context manager")
        }

        self.client = client

        let container = try decoder.singleValueContainer()

        self.id = try container.decode(Snowflake.self)
        self.type = .DMChannel
    }

}

public enum ChannelType {
    case DMChannel
}