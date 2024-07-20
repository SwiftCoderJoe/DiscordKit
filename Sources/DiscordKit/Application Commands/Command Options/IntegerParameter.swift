extension ApplicationCommand {
    struct IntegerParameter: CommandOption {
        let name: String
        let description: String
        let type: CommandOptionType = .integer
        let minimum: Int?
        let maximum: Int?
    }
}