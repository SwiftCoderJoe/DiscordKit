public struct Message {
    public var content: String

    var id: Snowflake

    public var channel: any IdentifiableTextChannel

    public var author: DiscordUser

    var _tempChannelId: Snowflake
}

extension Message: Decodable {
    enum CodingKeys: String, CodingKey {
        case content
        case id
        case author
        case channelId = "channel_id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.content = try container.decode(String.self, forKey: .content)
        self.id = try container.decode(Snowflake.self, forKey: .id)
        self.author = try container.decode(DiscordUser.self, forKey: .author)
        self._tempChannelId = try container.decode(Snowflake.self, forKey: .channelId)

        self.channel = try container.decode(TextChannelIdentifier.self, forKey: .channelId)
    }
}