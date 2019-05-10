import Vapor
import MongoKitten

struct Message: Content {
    let _id: ObjectId
    let message: String
    let userID: ObjectId
}

extension Message {

    static func from(_ doc: Document?) throws -> Message {
        guard let u = doc else {
            throw Abort(.badRequest, reason: "Invalid username or password")
        }
        let decoder = BSONDecoder()
        return try decoder.decode(Message.self, from: u)
    }

    static func from(_ doc: Document) throws -> Message {
        let decoder = BSONDecoder()
        return try decoder.decode(Message.self, from: doc)
    }

}
