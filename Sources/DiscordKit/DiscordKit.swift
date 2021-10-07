import Vapor

public struct Client {

    public init(print text: String) {

        print(text)

        var eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)

        do {
            try WebSocket.connect(to: "wss://gateway.discord.gg/?v=9&encoding=json", on: eventLoopGroup) { ws in
                // Connected WebSocket.
                print(ws)
                print("Connected.")

                ws.onText({ ws, text in 

                    let decoder = JSONDecoder()

                    guard let json = try? decoder.decode(WSPayload.self, from: text.data(using: .utf8)!) else {
                        print("epic fail")
                        return
                    }

                    print(json)
                        
                    
                })
            }.wait()
        } catch {
            print("epic fail 2")
        }

    }

    func login(with token: Token) {
        
    }

}

struct Token {
    let token: String

    public init(_ token: String) {
        self.token = token
    }
}

struct WSPayload: Decodable {
    let op: Int
    let d: WSPayloadData
    let s: Int?
    let t: String?
}

struct WSPayloadData: Decodable {
    let heartbeat_interval: Int
}