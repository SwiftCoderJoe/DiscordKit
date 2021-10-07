import XCTest
@testable import DiscordKit

final class DiscordKitTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let discordClient = Client(print: "Bruh momento")

        XCTAssertEqual(1, 1)
    }
}
