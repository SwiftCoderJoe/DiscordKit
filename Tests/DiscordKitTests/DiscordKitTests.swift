import XCTest
@testable import DiscordKit
import Logging

final class DiscordKitTests: XCTestCase {
    func testExample() async throws {
        let logger = Logger(label: "com.scj.Test")
        let intents: Intents = [.guilds, .guildMembers, .messages, .directMessages, .messageContent]
        let client = Client(token: "NTQyNDYxOTI3NDk1MDQxMDM0.XFoFCQ.cDSVnYrBCt3Rb36CaEvQ_TL0HHY", intents: intents, logLevel: .debug)

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

        client.onReady {
            try? await client.registerApplicationCommand(ApplicationCommand(name: "ping", description: "Ping pong!", type: .chat, options: []), in: Snowflake(542462471345274890)) {
                interaction in
                Task {
                    var string = ""
                    for message in try await client.getMessages(in: interaction.channel) {
                        string.append(message.content + "\n")
                    }
                    try await interaction.reply(saying: string)
                }
            }
        }

        try await client.login()

    }
}
