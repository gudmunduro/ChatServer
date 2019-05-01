import Vapor

struct User: Content {
    let _id: Int
    let username: String
    let password: String
}