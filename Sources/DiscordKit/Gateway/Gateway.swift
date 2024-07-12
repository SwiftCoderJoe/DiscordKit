import Vapor 

class Gateway {
    let client: Client
    let logger: Logger
    var heartbeatDispatch: DispatchSourceTimer?
    var eventLoop: EventLoopGroup
    var connection: WebSocket?

    private var heartbeatSequence: Int?
    private var heartbeatInterval: Int? {
        didSet {
            createHeartbeat(every: heartbeatInterval!)
        }
    }

    @discardableResult
    init(token: String, intents: Int, eventLoop: EventLoopGroup, logger: Logger, client: Client) async throws {
        self.client = client
        self.eventLoop = eventLoop
        self.logger = logger

        connection = try await WebSocket.connect(to: "wss://gateway.discord.gg/?v=10&encoding=json")
        logger.debug("WS Connected.")

        // When we've connected, log in.
        let properties = WSPayload.IdentifyData(token: token, intents: 4096)
        
        self.sendPayload(.identify(properties))

        guard let webSocketStream = connection?.listen() else { throw WebSocketListenError() }
        for await payload in webSocketStream {
            handle(payload: payload)
        }
    }

    private func handle(payload unidentifiedPayload: String) {

        let decoder = JSONDecoder()

        decoder.userInfo[.contextManager] = ContextManager(client: client)

        guard let payload = try? decoder.decode(WSPayload.self, from: unidentifiedPayload.data(using: .utf8)!) else {
            logger.error("Could not decode WebSocket payload.", metadata: ["Payload" : "\(unidentifiedPayload)"])
            return
        }

        switch payload {
            case .heartbeat:
                logger.warning("Recieved a heartbeat request, which is not yet implemented.")
            case .heartbeatAck:
                logger.info("Heartbeat was recieved by server.")
            case .gatewayHello(let data):
                heartbeatInterval = data.heartbeat_interval
            case .event(let event, let sequence):
                heartbeatSequence = sequence
                client.handle(event: event)
                
            default:
                // No other payload should ever be recieved
                print("Recieved an unknown payload, dumping:")
                dump(payload)
        }

    }

    private func createHeartbeat(every interval: Int) {

        let queue = DispatchQueue(label: "com.DiscordKit.client.heartbeatTimer")
        heartbeatDispatch = DispatchSource.makeTimerSource(queue: queue)
        // TODO: check if that leeway is small/large enough
        heartbeatDispatch?.schedule(deadline: .now() + .milliseconds(interval), repeating: .milliseconds(interval), leeway: .milliseconds(10))
        heartbeatDispatch?.setEventHandler { [weak self] in
            self?.logger.info("Sending heartbeat...")

            self?.sendPayload(.heartbeat(self?.heartbeatSequence))
            
        }
        heartbeatDispatch?.resume()
        
    }

    private func stopHeartbeat() {
        heartbeatDispatch?.cancel()
        heartbeatDispatch = nil
    }

    private func sendPayload(_ payload: WSPayload) {
        let encoder = JSONEncoder()

        let data = String(data: try! encoder.encode( payload ), encoding: .utf8)

        // For Gateway, since we don't use any of its return values, we really don't care what order or when tasks are executed.
        // No need to `await` anything.
        Task {
            try await self.connection!.send(data!)
        }
    }

    deinit {
        stopHeartbeat()
    }

    struct WebSocketListenError: Error { }
}