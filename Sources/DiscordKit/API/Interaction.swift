public struct Interaction {
    private let interactionID: Snowflake
    private let token: String
    private let api: RESTClient

    init(interactionID: Snowflake, token: String, api: RESTClient) {
        self.interactionID = interactionID
        self.token = token
        self.api = api
    }

    public func reply(saying content: String) async throws {
        api.replyToInteraction(id: interactionID, token: token, saying: content)
    }
}