import Vapor

struct UserTokenResponse: Content {
    let token: String
}