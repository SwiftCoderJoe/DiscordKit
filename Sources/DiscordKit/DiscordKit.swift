import Logging
import Vapor
import AsyncHTTPClient

public class Client: Eventable {

    private let token: String

    private var eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)

    private var connection: WebSocket?

    private var heartbeatInterval: Int? {
        didSet {
            createHeartbeat(every: heartbeatInterval!)
        }
    }

    private var heartbeatSequence: Int?

    private var logger = Logger(label: "com.scj.DiscordKit")

    private var httpClient = HTTPClient(eventLoopGroupProvider: .createNew)

    var heartbeatDispatch: DispatchSourceTimer?

    /// Event listener registry
    var listeners = [SubscribableEvent: [(Any) -> ()]]()

    public init(token: String) {

        self.token = token

    }

    func login() {

        let sema = DispatchSemaphore(value: 0) 

        // First, connect to the WebSocket. Set it so any payload recieved gets sent to handle(payload: WSPayload)
        let promise = WebSocket.connect(to: "wss://gateway.discord.gg/?v=9&encoding=json", on: eventLoopGroup) { ws in 
            // Connected WebSocket.
            
            print("Connected.")

            self.connection = ws

            ws.onText({ ws, text in 

                self.handle(payload: text)
                
            })
            
        }

        // When we've connected, log in.
        promise.whenComplete({ _ in

            let properties = WSPayload.IdentifyData(token: self.token, intents: 4096)
            
            self.sendPayload(.identify(properties))

            sema.signal()

        })

        sema.wait()

        RunLoop.main.run()
    }

    private func handle(payload unidentifiedPayload: String) {

        let decoder = JSONDecoder()

        decoder.userInfo[.contextManager] = ContextManager(client: self)

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
                handle(event: event)
                
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

    private func sendPayload(_ payload: WSPayload) {
        let encoder = JSONEncoder()

        let data = String(data: try! encoder.encode( payload ), encoding: .utf8)

        // print(data!)

        let promise = self.eventLoopGroup.next().makePromise(of: Void.self)
        self.connection!.send(data!, promise: promise)
        promise.futureResult.whenComplete { result in
            switch result {
            case .success():
                //print("Send success.")
                break
            case .failure(let error):
                print(error)
            }
        }
    }

    /** please move all WS code to Gateway */
    private func handle(event: Event) {
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

    private func stopHeartbeat() {
        heartbeatDispatch?.cancel()
        heartbeatDispatch = nil
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
        self.stopHeartbeat()
    }

}