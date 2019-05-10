import Vapor
import MongoKitten

struct User: Content {
    let _id: ObjectId
    let username: String
    let password: String
}

extension User {

    static func from(_ doc: Document?) throws -> User
    {
        guard let u = doc else {
            throw Abort(.badRequest, reason: "Invalid username or password")
        }
        let decoder = BSONDecoder()
        return try decoder.decode(User.self, from: u)
    }

    static func from(_ doc: Document) throws -> User
    {
        let decoder = BSONDecoder()
        return try decoder.decode(User.self, from: doc)
    }

}


// MARK: Public user data

struct UserPublic: Content {
    let _id: ObjectId
    let username: String
}