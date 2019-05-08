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

    func onText(_ ws: WebSocket, _ text: String, _ user: User, _ db: MongoKitten.Database)
    {
        print("Text sent", text)
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
        print("Broadcasting!")
        globalChatRoom.find().getAllResults().whenSuccess { messages in
            let jsonText = self.tempCreateJsonFromDocs(docs: messages)
            for user in self.users {
                guard user.ws !== socketToIgnore else {
                    continue
                }
                user.ws.send(jsonText)
            }
        }
    }

    func tempCreateJsonFromDocs(docs: [Document]) -> String {
        var jsonText = "["
        for doc in docs {
            jsonText += "{"
            for (key, value) in doc {
                var stringValue = "\(value)"
                stringValue = String(stringValue.filter { !" \n\r".contains($0) })
                jsonText += "\"\(key)\": \"\(stringValue)\", "
            }
            jsonText.removeLast()
            jsonText.removeLast()
            jsonText += "}, "
        }
        jsonText.removeLast()
        jsonText.removeLast()
        jsonText += "]"
        return jsonText
    }

}


// MARK: Old

final class ChatHandler {

    let user: User
    let db: MongoKitten.Database
    let globalChatRoom: MongoKitten.Collection

    init(ws: WebSocket, user: User, db: MongoKitten.Database) 
    {
        self.user = user
        self.db = db
        self.globalChatRoom = db["globalchatroom"]

        ws.onText(onText)
        ws.onClose.whenSuccess { _ in
            self.onClose()
        }
    }

    func onText(_ ws: WebSocket, _ text: String)
    {
        print("Text sent", text)
        if text.first ?? " " == ":" {
            print("Text is command")
            processCommand(text, ws: ws)
        } else {
            globalChatRoom.insert(["message": text, "userID": user._id])
        }
    }

    func processCommand(_ cmd: String, ws: WebSocket)
    {
        switch String(String(cmd.split(separator: " ")[0])) {
            case ":update":
                print("command is update")
                
                globalChatRoom.find().getAllResults().whenSuccess { messages in
                    let jsonText = self.tempCreateJsonFromDocs(docs: messages)
                    ws.send(jsonText)
                }
                break
            default: break
        }
    }

    func tempCreateJsonFromDocs(docs: [Document]) -> String {
        var jsonText = "["
        for doc in docs {
            jsonText += "{"
            for (key, value) in doc {
                var stringValue = "\(value)"
                stringValue = String(stringValue.filter { !" \n\r".contains($0) })
                jsonText += "\"\(key)\": \"\(stringValue)\", "
            }
            jsonText.removeLast()
            jsonText.removeLast()
            jsonText += "}, "
        }
        jsonText.removeLast()
        jsonText.removeLast()
        jsonText += "]"
        return jsonText
    }

    func onClose()
    {
        print("Connection closed")
    }

}