import Vapor
import MongoKitten

extension Request {

    func mongoDB() throws -> MongoKitten.Database {
        return try make(MongoKitten.Database.self)
    }

    func requireAuthenticated(_ db: MongoKitten.Database) throws -> Future<User> {
        guard let authHeader = self.http.headers.bearerAuthorization else {
            throw Abort(.badRequest, reason: "User is not logged in")
        }
        let token = authHeader.token

        return db["usertokens"].findOne("token" == token).flatMap { userToken -> Future<Document?> in

            guard let userID = userToken?["userID"] as? ObjectId else {
                throw Abort(.badRequest, reason: "User is not logged in(1)")
            }
            
            return db["users"].findOne("_id" == userID)
        }.map { user -> User in
            
            guard let u = user else {
                throw Abort(.badRequest, reason: "User is not logged in(2)")
            }

            do {
                try User.from(u)
            } catch {
                print(error)
            }
            
            
            return try User.from(u)
        }
    }

}