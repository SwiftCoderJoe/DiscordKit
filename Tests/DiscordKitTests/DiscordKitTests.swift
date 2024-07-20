import XCTest
@testable import DiscordKit
import Logging

final class DiscordKitTests: XCTestCase {
    func testExample() async throws {
        var client = Client(token: "NTQyNDYxOTI3NDk1MDQxMDM0.XFoFCQ.cDSVnYrBCt3Rb36CaEvQ_TL0HHY", logLevel: .debug)
        var logger = Logger(label: "com.scj.Test")

        client.onMessage { message in
            if message.author.bot ?? false {
                return
            }

            if message.content.starts(with: "echo ") {
                message.channel.send( String(message.content.dropFirst(5)) )
            }

            if message.content == "last10" {
                var string = ""
                do {
                    for message in try await message.channel.getMessages(limit: 10) {
                        string.append(message.content + "\n")
                    }
                    message.channel.send(string)
                } catch {
                    logger.error("\(error)")
                }
            }

        }

        try await client.login()

    }
}
