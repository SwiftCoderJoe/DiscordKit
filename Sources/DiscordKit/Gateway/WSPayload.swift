enum WSPayload: Codable {
    case heartbeat(Int?)                     // opcode 1
    case heartbeatAck                        // opcode 11
    case gatewayHello(GatewayHelloData)      // opcode 10
    case identify(IdentifyData)              // opcode 2
    case event(Event, Int)                   // opcode 0

    struct GatewayHelloData: Codable {
        let heartbeat_interval: Int
    }

    struct IdentifyData: Codable {

        init(token: String, intents: Int) {
            self.token = token
            self.intents = intents
            self.properties = IdentifyProperties()
        }

        let token: String
        let intents: Int
        let properties: IdentifyProperties

        struct IdentifyProperties: Codable {
            init() {
                #if os(macOS)
                    os = "macOS"
                #else
                    os = "Linux"
                #endif

                self.browser = "DiscordKit"
                self.device = "DiscordKit"
            }

            let os: String
            let browser: String
            let device: String

            enum CodingKeys: String, CodingKey {
                case os = "$os"
                case browser = "$browser"
                case device = "$device"
            }
        }
    }

}

extension WSPayload {
    enum Opcodes: Int, Codable {
        case heartbeat = 1
        case heartbeatAck = 11
        case gatewayHello = 10
        case identify = 2
        case event = 0
    }

    enum Events: String, Codable {
        case ready = "READY"
    }

    var opcode: Opcodes {
        switch self {
        case .heartbeat:
            return .heartbeat
        case .heartbeatAck:
            return .heartbeatAck
        case .gatewayHello:
            return .gatewayHello
        case .identify:
            return .identify
        case .event:
            return .event
        }
    }

    enum CodingKeys: String, CodingKey {
        case op
        case data = "d"
        case eventName = "t"
        case sessionID = "s"
    }

    func encode(to encoder: Encoder) throws {
        // type
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.opcode, forKey: .op)

        // Based on the type, encode data differently
        switch self {
            case .heartbeat(let data):
                try container.encode(data, forKey: .data)
            case .heartbeatAck:
                break
            case .gatewayHello(let data):
                try container.encode(data, forKey: .data)
            case .identify(let data):
                try container.encode(data, forKey: .data)
            case .event(let data, _):
                try container.encode(data, forKey: .data)
                // TODO: Implement
        }

    }

    init(from decoder: Decoder) throws {

        // Extract type  
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let opcode = try container.decode(Opcodes.self, forKey: .op)

        // Based on the type, extract different data
        switch opcode {
        case .heartbeat:
            // For a heartbeat, extract a raw Integer
            let specificData = try container.decode(Int.self, forKey: .data)
            self = .heartbeat(specificData)
        case .heartbeatAck:
            // For a heartbeat ack, extract nothing
            self = .heartbeatAck
        case .gatewayHello:
            // For a gateway hello, extract heartbeat_interval
            let specificData = try container.decode(GatewayHelloData.self, forKey: .data)
            self = .gatewayHello(specificData)
        case .identify:
            let specificData = try container.decode(IdentifyData.self, forKey: .data)
            self = .identify(specificData)
        case .event:
            // For an event, pass on the decoding to Event

            let eventName = try container.decode(String.self, forKey: .eventName)
            
            // Pass on the event name to Event
            if let eventNameContainer = decoder.userInfo[.contextManager] as? ContextManager {
                print("Event Name: \(eventName)")
                eventNameContainer.eventName = Event.Events(rawValue: eventName)
            } else {
                fatalError("Could not get eventNameContainer.")
            }

            let event = try container.decode(Event.self, forKey: .data)

            let sessionIdentifier = try container.decode(Int.self, forKey: .sessionID)
            self = .event(event, sessionIdentifier)
        }
    }
}

extension CodingUserInfoKey {
    static let contextManager = CodingUserInfoKey(rawValue: "ContextManager")!
}

class ContextManager {

    init(client: Client) {
        self.client = client
    }

    var eventName: Event.Events?

    var client: Client

}