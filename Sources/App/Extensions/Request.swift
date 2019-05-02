import Vapor
import MongoKitten

extension Request {

    func mongoDB() throws -> MongoKitten.Database {
        return try make(MongoKitten.Database.self)
    }

    func requireAuthenticated(_ db: MongoKitten.Database, customToken: String = "") throws -> Future<User> {
        guard let token = (customToken == "") ?
                            self.http.headers.bearerAuthorization?.token :
                            customToken else {
            throw Abort(.badRequest, reason: "User is not logged in")
        }

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