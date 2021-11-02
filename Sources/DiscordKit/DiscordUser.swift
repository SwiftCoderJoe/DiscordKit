struct DiscordUser {

    /** 
    User's full ID snowflake, stored in an Int for now. 
    */
    let id: Snowflake // Should be a snowflake?

    /** 
    User's plaintext username, stored in a String. 
    */
    let username: String

    /** 
    The Discord Tag of the user, stored in a String for now. 
    */
    let discriminator: String // should be an int?

    /** 
    NOT YET IMPLEMENTED 
    */
    //let avatar: String?

    /** 
    Shows if the user is part of an OAuth2 Application (is a bot) 
    
    Not sure why it's an optional
    */
    let bot: Bool?

    /** 
    Shows if the user is an official Discord System User 

    Currently shows up as nil, this should probably be decoded as false.
    */
    let system: Bool?
}

extension DiscordUser: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case username = "username"
        case discriminator = "discriminator"
        case bot = "bot"
        case system = "system"
    }
}