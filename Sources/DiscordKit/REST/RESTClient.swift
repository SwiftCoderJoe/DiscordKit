import AsyncHTTPClient
import Logging

class RESTClient {
    let token: String
    let logger: Logger
    let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)

    init(token: String, logger: Logger) {
        self.token = token
        self.logger = logger
    }

    func sendMessage(withText content: String, to channel: TextChannel) {
        var request = request(to: "channels/\(channel.id.string)/messages")

        request.body = .string("""
        {
            "content": "\(content)",
            "tts": false
        }
        """)

        execute(request: request)
    }

    private func request(to endpoint: String) -> HTTPClient.Request{
        var request = try! HTTPClient.Request(url: "https://discord.com/api/\(endpoint)", method: .POST)

        request.headers.add(name: "User-Agent", value: "DiscordBot (https://github.com/SwiftCoderJoe/DiscordKit/, 1.0.0")
        request.headers.add(name: "Authorization", value: "Bot \(token)")
        request.headers.contentType = .json

        return request
    }

    private func execute(request: HTTPClient.Request) {
        httpClient.execute(request: request).whenComplete { result in
            switch result {
            case .failure(let error):
                self.logger.critical("\(error)")
            case .success(let response):
                if response.status == .ok {
                    self.logger.info("REST request performed successfully.")
                } else {
                    self.logger.critical("A REST request had an error. Dumping the request and the response:")
                    dump(request)
                    dump(response)
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