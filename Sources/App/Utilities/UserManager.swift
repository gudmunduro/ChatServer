import Vapor
import Crypto
import MongoKitten

final class UserManager {

    static func login(db: MongoKitten.Database, username: String, password: String) throws -> Future<UserTokenResponse> 
    {
        let users = db["users"]
        return users.findOne("username" == username).map { user -> User in
            guard let u = user, let checkPass = u["password"] as? String, try BCrypt.verify(password, created: checkPass) else {
                throw Abort(.badRequest, reason: "Invalid username or password")
            }
            let decoder = BSONDecoder()
            return try decoder.decode(User.self, from: u)
        }.flatMap { user -> Future<(InsertReply, String)> in
            let token = try CryptoRandom().generateData(count: 16).base64EncodedString()

            return try db["usertokens"].insert(["token": token, "userID": user._id]).and(result: token)
        }.map { _, token in
            return UserTokenResponse(token: token)
        }
    }

    static func create(db: MongoKitten.Database, username: String, password: String) throws -> Future<InsertReply>
    {
        let users = db["users"]
        let passwordHash = try BCrypt.hash(password, cost: 4)
        return users.insert(["username": username, "password": passwordHash])
    }

}