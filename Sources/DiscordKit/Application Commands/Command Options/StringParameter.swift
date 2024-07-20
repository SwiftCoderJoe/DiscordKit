extension ApplicationCommand {
    struct StringParameter: CommandOption {
        let name: String
        let description: String
        let type: CommandOptionType = .string
    }
}