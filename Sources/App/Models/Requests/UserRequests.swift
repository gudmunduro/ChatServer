import Vapor

struct CreateUserRequest: Content {
    let username: String
    let password: String
    let verifyPassword: String
}