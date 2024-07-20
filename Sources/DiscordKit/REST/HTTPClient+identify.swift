import AsyncHTTPClient

extension HTTPClient.Request {
    mutating func identify(_ token: String) {
        self.headers.add(name: "User-Agent", value: "DiscordBot (https://github.com/SwiftCoderJoe/DiscordKit/, 1.0.0")
        self.headers.add(name: "Authorization", value: "Bot \(token)")
        self.headers.contentType = .json
    }
}