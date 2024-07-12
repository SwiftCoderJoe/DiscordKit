import XCTest
@testable import DiscordKit

final class DiscordKitTests: XCTestCase {
    func testExample() async throws {
        
        var client = Client(token: "NTQyNDYxOTI3NDk1MDQxMDM0.XFoFCQ.cDSVnYrBCt3Rb36CaEvQ_TL0HHY", logLevel: .debug)

        client.on(.message) { data in
            var message = data as! Message

            if message.author.bot ?? false {
                return
            }

            if message.content.starts(with: "echo ") {
                message.channel.send( String(message.content.dropFirst(5)) )
            }

            if message.content == "sing" {
                message.channel.send("I'm singing!")
            }

        }

        try await client.login()

    }
}
