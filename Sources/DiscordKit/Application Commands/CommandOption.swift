extension ApplicationCommand {
    public protocol CommandOption: Encodable {
        var name: String { get }
        var description: String { get }
        var type: CommandOptionType { get }
    }

    public enum CommandOptionType: Int, Codable {
        case string = 3
        case integer = 4
    }
}