import Vapor

extension WebSocket {
    /// Returns both a WebSocket connection and a never-ending asynchronous stream of WebSocket payloads.
    static func connect(
        to url: String,
        headers: HTTPHeaders = [:],
        configuration: WebSocketClient.Configuration = .init(maxFrameSize: 1 << 16),
        on eventLoopGroup: any EventLoopGroup = MultiThreadedEventLoopGroup.singleton,
        logger: Logger
    ) async -> (WebSocket, AsyncStream<String>) {
        await withCheckedContinuation { continuation in
            _ = WebSocket.connect(to: url, headers: headers, configuration: configuration, on: eventLoopGroup) { ws in
                let stream = AsyncStream(String.self) { streamContinuation in
                    ws.onText { _, text in
                        streamContinuation.yield(text)
                    }
                }
                continuation.resume(returning: (ws, stream))
            }
        }
    }
}