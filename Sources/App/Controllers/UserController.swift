import Vapor
import MongoKitten

final class UserController {

    func create(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.content.decode(CreateUserRequest.self).map { userData throws -> CreateUserRequest in
            guard userData.password == userData.verifyPassword else {
                throw Abort(.badRequest, reason: "Verify password invalid")
            }
            return userData
        }.flatMap { userData -> Future<InsertReply> in 
            let db = try req.mongoDB()
            return try UserManager.create(db: db, username: userData.username, password: userData.password)
        }.map { _ -> HTTPStatus in
            return .ok
        }
    }

    func login(_ req: Request) throws -> Future<UserTokenResponse> {
        let db = try req.mongoDB()
        guard let authHeader = req.http.headers.basicAuthorization else {
            throw Abort(.badRequest, reason: "No username or password in request")
        }
        
        return try UserManager.login(db: db, username: authHeader.username, password: authHeader.password)
    }

    func allUsers(_ req: Request) throws -> Future<[UserPublic]> {
        let db = try req.mongoDB()
        return try UserManager.allUsersPublicData(db: db)
    }
}