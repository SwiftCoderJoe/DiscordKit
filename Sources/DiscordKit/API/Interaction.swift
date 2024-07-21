public struct Interaction {
    private let interactionID: Snowflake
    private let token: String
    private let api: RESTClient
    private let client: Client

    public let channel: any IdentifiableTextChannel
    public let guildID: Snowflake?

    // TODO: Could add a ref to the user / guildmember here
    init(interactionID: Snowflake, token: String, guildID: Snowflake?, channel: any IdentifiableTextChannel, client: Client, api: RESTClient) {
        self.interactionID = interactionID
        self.token = token
        self.channel = channel
        self.guildID = guildID
        self.client = client
        self.api = api
    }

    public func reply(saying content: String) async throws {
        api.replyToInteraction(id: interactionID, token: token, saying: content)
    }
}