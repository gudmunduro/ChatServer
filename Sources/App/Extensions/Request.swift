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

        return db["usertokens"].findOne("token" == token).flatMap { userToken in
            return db["users"].findOne("_id" == (userToken?["userID"] as? String ?? ""))
        }.map { user -> User in
            guard let u = user else {
                throw Abort(.badRequest, reason: "Invalid username or password")
            }
            let decoder = BSONDecoder()
            return try decoder.decode(User.self, from: u)
        }
    }

}