import Logging
import Vapor
import AsyncHTTPClient

public class Client {

    private let token: String
    private var applicationID: Snowflake? = nil
    private var ready: Bool = false

    private let intents: Intents

    private var logger = Logger(label: "com.scj.DiscordKit")

    private var api: RESTClient!

    // MARK: Instantiation

    public init(token: String, intents: Intents = .unprivileged, logLevel: Logger.Level = .info) {
        self.token = token
        self.intents = intents
        logger.logLevel = logLevel
        api = RESTClient(token: token, logger: logger, client: self)
    }

    /// Log into Discord.
    /// 
    /// When the bot logs in and is ready for new commands, the `ready` event will be emitted. This can be 
    /// listened for using ``Client/onReady(execute:)``
    public func login() async throws {
        try await Gateway(token: token, intents: intents, logger: logger, client: self)
        logger.critical("SHOULD NEVER PRINT! If this message is printed, something in the Swift language has gone seriously wrong.")
    }

    // MARK: Client functions

    public func send(text content: String, to channel: any IdentifiableTextChannel) {
        api.sendMessage(withText: content, to: channel)
    }

    // TODO: make one requiring only Snowflake?
    public func getMessage(in channel: any IdentifiableTextChannel, id: Snowflake) async throws -> Message {
        return try await api.getMessage(from: channel.id, id: id)
    }

    public func getMessages(in channel: any IdentifiableTextChannel, limit: Int = 10) async throws -> [Message] {
        return try await api.getMessages(from: channel.id, limit: limit)
    }
    
    // MARK: Events

    func handle(event: Event) {
        switch event {
        case .ready(let data):
            ready = true
            applicationID = data.application.id
            api.applicationID = data.application.id
            logger.info("Logged in!")
            emitOnReady()
        case .message(let message):
            emitOnMessage(with: message)
        case .interaction(let interactionEvent):
            handleInteraction(interactionEvent)
        case .unknown(let name):
            logger.warning("Recieved an unknown event.", metadata: ["Event name": "\(name)"])
        }
    }

    var messageEventCallbacks: [(Message) -> ()] = []
    var messageEventAsyncCallbacks: [(Message) async -> ()] = []
    public func onMessage(execute callback: @escaping (Message) -> ()) {
        messageEventCallbacks.append(callback)
    }
    public func onMessage(exute asyncCallback: @escaping (Message) async -> ()) {
        messageEventAsyncCallbacks.append(asyncCallback)
    }
    private func emitOnMessage(with message: Message) {
        for callback in messageEventCallbacks {
            callback(message)
        }
        for asyncCallback in messageEventAsyncCallbacks {
            Task {
                await asyncCallback(message)
            }
        }
    }

    var readyEventCallbacks: [() -> ()] = []
    var readyEventAsyncCallbacks: [() async -> ()] = []
    public func onReady(execute callback: @escaping () -> ()) {
        readyEventCallbacks.append(callback)
    }
    public func onReady(exute asyncCallback: @escaping () async -> ()) {
        readyEventAsyncCallbacks.append(asyncCallback)
    }
    private func emitOnReady() {
        for callback in readyEventCallbacks {
            callback()
        }
        for asyncCallback in readyEventAsyncCallbacks {
            Task {
                await asyncCallback()
            }
        }
    }

    // MARK: Slash Commands

    var applicationCommandCallbacks: [Snowflake: (Interaction) -> ()] = [:]

    private func handleInteraction(_ interactionEvent: InteractionEvent) {
        switch interactionEvent.type {
            case .applicationCommand:
                guard case let .applicationCommand(data) = interactionEvent.data else { fatalError() }
                let interaction = Interaction(interactionID: interactionEvent.id, token: interactionEvent.token, guildID: interactionEvent.guildID, channel: interactionEvent.channel, client: self, api: api)
                guard let callback = applicationCommandCallbacks[data.commandID] else { return } // Maybe something else?
                callback(interaction)
            default:
                logger.debug("Ignoring unknown interaction event.")
        }
    }

    // TODO: We should eventually move this system to result builders, just like the *other* SwiftKit.
    public func registerApplicationCommand(_ command: ApplicationCommand, in guild: Snowflake, callback: @escaping (Interaction) -> ()) async throws {
        guard ready else { throw ClientError.applicationNotReadyError }

        let id = try await api.register(command: command, in: guild)
        applicationCommandCallbacks[id] = callback
    }

    // MARK: Cleanup & Shutdown

    deinit { }

    enum ClientError: Error {
        case applicationNotReadyError
    }
}