import Vapor
import NullCodable

public class Client {

    var eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)

    var connection: WebSocket?

    var encoder = JSONEncoder()

    var decoder = JSONDecoder()

    var heartbeatInterval: Int? {
        didSet {
            createHeartbeat(every: heartbeatInterval!)
        }
    }

    var heartbeatDispatch: DispatchSourceTimer?

    public init(print text: String) {

        let _ = WebSocket.connect(to: "wss://gateway.discord.gg/?v=9&encoding=json", on: eventLoopGroup) { ws in // wss://demo.piesocket.com/v3/channel_1?api_key=oCdCMcMPQpbvNjUIzqtvF1d2X2okWpDQj4AwARJuAgtjhzKxVEjQU6IdCjwm&notify_self
            // Connected WebSocket.
            
            print("Connected.")
            print("Sending WS connection to the client...")

            self.connection = ws

            ws.onText({ ws, text in 

                print(text)

                let decoder = JSONDecoder()

                guard let json = try? decoder.decode(WSPayload.self, from: text.data(using: .utf8)!) else {
                    print("epic fail")
                    return
                }

                // self.heartbeatInterval = json.d.heartbeat_interval
                self.handle(payload: json)
                    
                
            })

            
            
        }

    }

    func login(with token: Token) {
        
    }

    private func handle(payload: WSPayload) {

        switch payload {
            case .heartbeat:
                print("I should probably do something...")
            case .heartbeatAck:
                print("Heartbeat was recieved by server.")
            case .gatewayHello(let data):
                heartbeatInterval = data.heartbeat_interval
        }

    }

    private func createHeartbeat(every interval: Int) {

        let queue = DispatchQueue(label: "com.DiscordKit.client.heartbeatTimer")
        heartbeatDispatch = DispatchSource.makeTimerSource(queue: queue)
        // TODO: check if that leeway is small/large enough
        heartbeatDispatch?.schedule(deadline: .now() + .milliseconds(interval), repeating: .milliseconds(interval), leeway: .milliseconds(10))
        heartbeatDispatch?.setEventHandler { [weak self] in
            print("sending heartbeat...")

            self?.sendPayload()
            
        }
        heartbeatDispatch?.resume()
        
    }

    private func sendPayload() {
        let data = String(data: try! encoder.encode( op1() ), encoding: .utf8)
        let promise = self.eventLoopGroup.next().makePromise(of: Void.self)
        self.connection!.send(data!, promise: promise)
        promise.futureResult.whenComplete { result in
            switch result {
            case .success():
                print("opcode1 sent.")
            case .failure(let error):
                print(error)
            }
        }
    }

    private func stopHeartbeat() {
        heartbeatDispatch?.cancel()
        heartbeatDispatch = nil
    }

    deinit {
        self.stopHeartbeat()
    }

}

struct Token {
    let token: String

    public init(_ token: String) {
        self.token = token
    }
}

struct op1: Codable {
    var op: Int = 1
    @NullCodable var d: Int? = nil
}

enum WSPayload: Codable {
    case heartbeat(Int?)                      // opcode 1
    case heartbeatAck                        // opcode 11
    case gatewayHello(GatewayHelloData)      // opcode 10

    struct GatewayHelloData: Codable {
        let heartbeat_interval: Int
    }

}

extension WSPayload {
    enum Types: Int, Codable {
        case heartbeat = 1
        case heartbeatAck = 11
        case gatewayHello = 10
    }

    var type: Types {
        switch self {
        case .heartbeat:
            return .heartbeat
        case .heartbeatAck:
            return .heartbeatAck
        case .gatewayHello:
            return .gatewayHello
        }
    }

    enum CodingKeys: String, CodingKey {
        case op
        case d
    }

    func encode(to encoder: Encoder) throws {
        // type
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type, forKey: .op)

        // Based on the type, encode data differently
        switch self {
            case .heartbeat(let data):
                try container.encode(data, forKey: .d)
            case .heartbeatAck:
                break
            case .gatewayHello(let data):
                try container.encode(data, forKey: .d)
        }

    }

    init(from decoder: Decoder) throws {

        // Extract type  
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Types.self, forKey: .op)

        // Based on the type, extract different data
        switch type {
            case .heartbeat:
                // For a heartbeat, extract a raw Integer
                let specificData = try container.decode(Int.self, forKey: .d)
                self = .heartbeat(specificData)
            case .heartbeatAck:
                // For a heartbeat ack, extract nothing
                self = .heartbeatAck
            case .gatewayHello:
                // For a gateway hello, extract heartbeat_interval
                let specificData = try container.decode(GatewayHelloData.self, forKey: .d)
                self = .gatewayHello(specificData)
        }
    }
}
