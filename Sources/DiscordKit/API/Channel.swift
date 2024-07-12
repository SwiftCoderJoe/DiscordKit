protocol Channel: Codable {

    var client: Client { get }

    var id: Snowflake { get }

    // var type: ChannelType { get }

}

protocol TextChannel: Channel {
    
}

extension TextChannel {
    func send(_ content: String) {
        client.send(text: content, to: self)
    }
}

struct DMChannel: TextChannel {

    var client: Client

    var id: Snowflake

    // var type: ChannelType

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

    }

}

enum ChannelType {
    case DMChannel
}