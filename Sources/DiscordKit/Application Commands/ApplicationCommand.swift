public struct ApplicationCommand {
    let name: String
    let description: String
    let type: ApplicationCommandType
    let options: [any CommandOption]

    public init(name: String, description: String, type: ApplicationCommandType, options: [any CommandOption] = []) {
        self.name = name
        self.description = description
        self.type = type
        self.options = options
    }

    public enum ApplicationCommandType: Int, Codable {
        case chat = 1
        case user = 2
        case message = 3
    }
}

extension ApplicationCommand: Encodable {
    enum CodingKeys: String, CodingKey {
        case name, description, type, options
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(type, forKey: .type)

        var optionsContainer = container.nestedUnkeyedContainer(forKey: .options)
        for option in options {
            try optionsContainer.encode(option)
        }
    }
}