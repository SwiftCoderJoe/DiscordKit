struct Snowflake: Equatable {
    init(_ int: Int) {
        self.int = int
        self.string = String(int)
    }

    init(_ string: String) throws {
        guard let int = Int(string) else { 
            fatalError()
        }
        self.int = int
        self.string = string
    }

    /** Snowflake represented as an Int */
    var int: Int

    /** Snowflake represented as a String */
    var string: String
}

extension Snowflake: Codable {
    func encode(to encoder: Encoder) throws {
        fatalError("Errored while trying to encode a snowflake. this isnt implemented yet lmao")
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        string = try container.decode(String.self)
        self = try Snowflake(string)
    }
}