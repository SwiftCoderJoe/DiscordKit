extension ApplicationCommand {
    protocol CommandOption: Encodable {
        var name: String { get }
        var description: String { get }
        var type: CommandOptionType { get }
    }

    enum CommandOptionType: Int, Codable {
        case string = 3
        case integer = 4
    }
}