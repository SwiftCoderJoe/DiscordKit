import AsyncHTTPClient
import Foundation
import NIOCore
import NIOFoundationCompat
import Logging

class RESTClient {
    let logger: Logger
    let client: Client

    let token: String
    var applicationID: Snowflake? = nil

    let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)

    init(token: String, logger: Logger, client: Client) {
        self.token = token
        self.logger = logger
        self.client = client
    }

    // MARK: API

    func sendMessage(withText content: String, to channel: any IdentifiableTextChannel) {
        var request = post("channels/\(channel.id.string)/messages")

        request.body = .string("""
        {
            "content": \(content.jsonEncoded),
            "tts": false
        }
        """)

        execute(request)
    }

    func getMessage(from channelID: Snowflake, id messageID: Snowflake) async throws -> Message {
        let request = get("channels/\(channelID.string)/messages/\(messageID.string)")
        return try await getResult(of: request, as: Message.self)
    }
    
    func getMessages(from channelID: Snowflake, limit: Int = 10) async throws -> [Message] {
        let request = get("channels/\(channelID.string)/messages?limit=\(limit)")
        return try await getResult(of: request, as: [Message].self)
    }

    // MARK: Application commands

    func register(command: ApplicationCommand, in guild: Snowflake) async throws -> Snowflake {
        var request = post("applications/\(applicationID!.string)/commands")
        do {
            request.body = .byteBuffer(try JSONEncoder().encodeAsByteBuffer(command, allocator: ByteBufferAllocator()))
        } catch {
            throw RESTError.couldNotEncodeError
        }
        return try await getResult(of: request, as: ApplicationCommandCreated.self).id
    }

    func replyToInteraction(id: Snowflake, token: String, saying content: String) {
        var request = post("interactions/\(id.string)/\(token)/callback")

        request.body = .string("""
        {
            "type": 4,
            "data": {
                "content": \(content.jsonEncoded)
            }
        }
        """)

        execute(request)
    }

    // MARK: Utilities

    private func get(_ endpoint: String) -> HTTPClient.Request {
        var request = try! HTTPClient.Request(url: "https://discord.com/api/v10/\(endpoint)", method: .GET)
        request.identify(token)
        return request
    }

    private func post(_ endpoint: String) -> HTTPClient.Request{
        var request = try! HTTPClient.Request(url: "https://discord.com/api/v10/\(endpoint)", method: .POST)
        request.identify(token)
        return request
    }

    private func execute(_ request: HTTPClient.Request) {
        httpClient.execute(request: request).whenComplete { result in
            switch result {
            case .failure(let error):
                self.logger.critical("\(error)")
            case .success(let response):
                if response.status == .ok || response.status == .noContent {
                    self.logger.info("REST request performed successfully.")
                } else {
                    self.logger.critical("A REST request had an error. Dumping the request and the response.", metadata: ["request": "\(request)", "response": "\(response)"])
                    dump(request)
                    dump(response)
                }
            }
        }
    }

    private func getResult<T: Decodable>(of request: HTTPClient.Request, as type: T.Type) async throws -> T {
        let result = try await httpClient.execute(request: request).get()
        guard result.status == .ok || result.status == .created else { throw RESTError.responseNotOKError }
        guard let body = result.body else { throw RESTError.emptyResponseError }

        let decoder = JSONDecoder()
        decoder.userInfo[.contextManager] = ContextManager(client: client)
        return try decoder.decode(type, from: body)
    }

    deinit {
        do {
            try httpClient.syncShutdown()
        } catch {
            logger.error("Could not shut down the HTTP client.")
        }
    }

    enum RESTError: Error {
        case responseNotOKError
        case emptyResponseError
        case couldNotEncodeError
    }
}