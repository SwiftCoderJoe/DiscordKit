import Logging
import Vapor
import AsyncHTTPClient

public class Client {

    private let token: String

    private var logger = Logger(label: "com.scj.DiscordKit")

    private var api: RESTClient

    // MARK: Instantiation

    public init(token: String, logLevel: Logger.Level = .info) {
        self.token = token
        logger.logLevel = logLevel
        api = RESTClient(token: token, logger: logger)
    }

    func login() async throws {
        try await Gateway(token: token, intents: 37379, logger: logger, client: self)
        logger.critical("SHOULD NEVER PRINT! If this message is printed, something in the Swift language has gone seriously wrong.")
    }

    // MARK: Client functions

    public func send(text content: String, to channel: TextChannel) {
        api.sendMessage(withText: content, to: channel)
    }
    
    // MARK: Events

    func handle(event: Event) {
        switch event {
        case .ready(_):
            logger.info("Logged in!")
        case .message(let message):
            emitOnMessage(with: message)
        case .unknown(let name):
            logger.warning("Recieved an unknown event.", metadata: ["Event name": "\(name)"])
        }
    }

    var messageEventCallbacks: [(Message) -> ()] = []
    public func onMessage(execute callback: @escaping (Message) -> ()) {
        messageEventCallbacks.append(callback)
    }
    private func emitOnMessage(with message: Message) {
        for callback in messageEventCallbacks {
            callback(message)
        }
    }

    // MARK: Cleanup & Shutdown

    deinit { }
}