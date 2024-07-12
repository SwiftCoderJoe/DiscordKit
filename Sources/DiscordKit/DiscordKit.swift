import Logging
import Vapor
import AsyncHTTPClient

public class Client: Eventable {

    private let token: String

    private let eventLoopGroup = MultiThreadedEventLoopGroup.singleton

    private var logger = Logger(label: "com.scj.DiscordKit")

    private var httpClient: HTTPClient!

    var heartbeatDispatch: DispatchSourceTimer?

    /// Event listener registry
    var listeners = [SubscribableEvent: [(Any) -> ()]]()

    public init(token: String, logLevel: Logger.Level = .info) {
        self.token = token
        logger.logLevel = logLevel

        httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
    }

    func login() async throws {
        try await Gateway(token: token, intents: 4096, eventLoop: eventLoopGroup, logger: logger, client: self)
        logger.critical("SHOULD NEVER PRINT!!!!!")
    }

    func handle(event: Event) {
        switch event {
        case .ready(_):
            logger.info("Logged in!")
        case .message(_):
            emit(event)
        case .unknown(let decoder):
            dump(decoder)
            logger.warning("Recieved an unknown event.")
        }
    }

    func send(text content: String, to channel: TextChannel) {
        var request = try! HTTPClient.Request(url: "https://discord.com/api/channels/\(channel.id.string)/messages", method: .POST)

        request.headers.add(name: "User-Agent", value: "DiscordBot (https://github.com/SwiftCoderJoe/DiscordKit/, 1.0.0")
        request.headers.add(name: "Authorization", value: "Bot \(token)")
        request.headers.contentType = .json

        request.body = .string("""
        {
            "content": "\(content)",
            "tts": false
        }
        """)

        httpClient.execute(request: request).whenComplete { result in
            switch result {
            case .failure(let error):
                self.logger.critical("\(error)")
            case .success(let response):
                if response.status == .ok {
                    self.logger.info("Sent message successfully.")
                } else {
                    self.logger.critical("Something went wrong!")
                    dump(response)
                    print(response.body)
                }
            }
        }
    }

    deinit {
        do {
            try httpClient.syncShutdown()
        } catch {
            logger.error("Could not shut down the HTTP client.")
        }
    }
}