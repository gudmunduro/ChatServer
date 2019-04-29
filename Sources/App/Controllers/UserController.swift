import Vapor
import MongoKitten

final class UserController {

    func create(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(UserCreateRequst.self).flatMap { userData throws -> Future<(MongoKitten.Database, UserCreateRequst)> in
            guard userData.password == userData.verifyPassword else {
                throw Abort(.badRequest, reason: "Verify password invalid")
            }
            return try req.make(Future<MongoKitten.Database>.self).and(result: userData)
        }.flatMap { database, userData -> Future<InsertReply> in 
            let users = database["users"]
            return users.insert(["username": "test", "password": "ab123"])
        }.map { _ -> HTTPStatus in
            return .ok
        }
    }

    func login(_ req: Request) throws -> Future<User> {
        return try req.make(Future<MongoKitten.Database>.self).flatMap { database -> Future<Document?> in
            let users = database["users"]
            return users.findOne("username" == "test")
        }.map { user in
            guard let u = user else {
                throw Abort(.badRequest, reason: "Invalid username or password")
            }
            let decoder = BSONDecoder()
            return try decoder.decode(User.self, from: u)
        }
    }
}

// MARK: Request data

struct User: Content {
    let username: String
    let password: String
}

struct UserCreateRequst: Content {
    let username: String
    let password: String
    let verifyPassword: String
}