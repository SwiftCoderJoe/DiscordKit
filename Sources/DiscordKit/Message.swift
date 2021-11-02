struct Message {
    var content: String

    var id: Snowflake

    var channel: TextChannel

    var author: DiscordUser

    var _tempChannelId: Snowflake
}

extension Message: Codable {
    enum CodingKeys: String, CodingKey {
        case content
        case id
        case author
        case channelId = "channel_id"
        
    }

    func encode(to encoder: Encoder) throws {
        fatalError("Not implemented")
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.content = try container.decode(String.self, forKey: .content)
        self.id = try container.decode(Snowflake.self, forKey: .id)
        self.author = try container.decode(DiscordUser.self, forKey: .author)
        self._tempChannelId = try container.decode(Snowflake.self, forKey: .channelId)

        self.channel = try container.decode(DMChannel.self, forKey: .channelId)
    }
}