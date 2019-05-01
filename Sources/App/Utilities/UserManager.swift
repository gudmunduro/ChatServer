import Vapor
import Crypto
import MongoKitten

final class UserManager {

    static func login(db: MongoKitten.Database, username: String, password: String) throws -> Future<UserTokenResponse> 
    {
        let users = db["users"]
        return users.findOne("username" == username).map { user -> Document in
            guard let u = user, let checkPass = u["password"] as? String, try BCrypt.verify(password, created: checkPass) else {
                throw Abort(.badRequest, reason: "Invalid username or password")
            }
            return u
        }.flatMap { user -> Future<(InsertReply, String)> in
            let token = try CryptoRandom().generateData(count: 16).base64EncodedString()
            print(user)
            guard let userID = user["_id"] as? ObjectId else {
                throw Abort(.internalServerError, reason: "Failed to get user id")
            }

            return db["usertokens"].insert(["token": token, "userID": userID]).and(result: token)
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

    static func allUsersPublicData(db: MongoKitten.Database) throws -> Future<[UserPublic]>
    {
        return db["users"].find().getAllResults().map { users in
            let decoder = BSONDecoder()
            var decodedUsers: [UserPublic] = []
            
            for user in users {
                decodedUsers.append(try decoder.decode(UserPublic.self, from: user))
            }

            return decodedUsers
        }
    }

}