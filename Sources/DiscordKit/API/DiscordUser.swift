struct DiscordUser {

    /** 
    User's full ID snowflake
    */
    let id: Snowflake

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
        case id
        case username
        case discriminator
        case bot
        case system
    }
}