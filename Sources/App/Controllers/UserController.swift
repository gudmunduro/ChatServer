import Vapor
import MongoKitten

final class UserController {

    func create(_ req: Request) {
        return try req.content.decode(UserCreateRequst.self).map { userData in
            guard userData.password == userData.verifyPassword else {
                throw Abort(.badRequst, reason: "Verify password invalid")
            }
            return try req.make(Future<MongoKitten.Database>.self).and(result: userData)
        }.flatMap(to: [User].self) { database, userData in 
            return HTTPStatus.ok
        }
    }

    func login() {

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