public struct Intents: OptionSet, Encodable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    static public let guilds = Self(rawValue: 1 << 0)
    static public let guildMembers = Self(rawValue: 1 << 1)
    static public let guildModeration = Self(rawValue: 1 << 2)
    static public let emojisAndStickers = Self(rawValue: 1 << 3)
    static public let integrations = Self(rawValue: 1 << 4)
    static public let webhooks = Self(rawValue: 1 << 5)
    static public let invites = Self(rawValue: 1 << 6)
    static public let voiceStates = Self(rawValue: 1 << 7)
    static public let presences = Self(rawValue: 1 << 8)
    static public let messages = Self(rawValue: 1 << 9)
    static public let messageReactions = Self(rawValue: 1 << 10)
    static public let messageTyping = Self(rawValue: 1 << 11)
    static public let directMessages = Self(rawValue: 1 << 12)
    static public let directMessageReactions = Self(rawValue: 1 << 13)
    static public let directMessageTyping = Self(rawValue: 1 << 14)
    static public let messageContent = Self(rawValue: 1 << 15)
    static public let scheduledEvents = Self(rawValue: 1 << 16)
    static public let automodConfig = Self(rawValue: 1 << 20)
    static public let automodExecution = Self(rawValue: 1 << 21)
    static public let guildPolls = Self(rawValue: 1 << 24)
    static public let directMessagePolls = Self(rawValue: 1 << 25)

    static public let unprivileged: Self = [.guilds, .guildModeration, .emojisAndStickers, .integrations, .webhooks, .invites, .voiceStates, .messages, .messageReactions, .messageTyping, .directMessages, .directMessageReactions, .directMessageTyping, .scheduledEvents, .automodConfig, .automodExecution]
    static public let privileged: Self = [.guildMembers, .presences, .messageContent]
    static public let all: Self = [.unprivileged, .privileged]
}