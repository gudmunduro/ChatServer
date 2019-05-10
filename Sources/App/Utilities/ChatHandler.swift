import Vapor
import MongoKitten

final class ChatRoom {

    var users: [(ws: WebSocket, user: User, db: MongoKitten.Database)] = []

    func addUser(ws: WebSocket, user: User, db: MongoKitten.Database) {
        users.append((ws: ws, user: user, db: db))
        ws.onText { ws, text in
            self.onText(ws, text, user, db)
        }
        ws.onClose.whenSuccess { _ in
            self.onClose(ws)
        }
    }

    func onText(_ ws: WebSocket, _ text: String, _ user: User, _ db: MongoKitten.Database) {
        let globalChatRoom = db["globalchatroom"]
        globalChatRoom.insert(["message": text, "userID": user._id])
        broadcast(globalChatRoom, except: ws)
    }

    func onClose(_ ws: WebSocket) {
        for i in 0..<users.count {
            if ws === users[i].ws {
                users.remove(at: i)
            }
        }
    }

    func broadcast(_ globalChatRoom: MongoKitten.Collection, except socketToIgnore: WebSocket) {
        globalChatRoom.find().getAllResults().whenSuccess { messages in
            do {
                let jsonText = try self.createJsonFromDocs(docs: messages)
                for user in self.users {
                    guard user.ws !== socketToIgnore else {
                        continue
                    }
                    user.ws.send(jsonText)
                }
            } catch {
                print(error)
            }
        }
    }

    func createJsonFromDocs(docs: [Document]) throws -> String {
        let jsonData = try JSONEncoder().encode(docs)
        return String(data: jsonData, encoding: String.Encoding.utf8)!
    }

}
