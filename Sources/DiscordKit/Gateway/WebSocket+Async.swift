import Vapor

extension WebSocket {
    static func connect(
        to url: String,
        headers: HTTPHeaders = [:],
        configuration: WebSocketClient.Configuration = .init(),
        on eventLoopGroup: any EventLoopGroup = MultiThreadedEventLoopGroup.singleton
    ) async throws -> WebSocket {
        try await withCheckedThrowingContinuation { continuation in
            let promise = WebSocket.connect(to: url, headers: headers, configuration: configuration, on: eventLoopGroup) { ws in
                continuation.resume(returning: ws)
            }
            do {
                try promise.wait()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// A never-finishing asynchronous stream that yields WebSocket payloads.
    func listen() -> AsyncStream<String> {
        return AsyncStream(String.self) { continuation in
            self.eventLoop.execute {
                self.onText { _, text in
                    continuation.yield(text)
                }
            }
        }
    }
}