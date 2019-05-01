import Vapor
import MongoKitten

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
            processCommand(String(text[...text.index(text.endIndex, offsetBy: -2)]), ws: ws)
        } else {
            globalChatRoom.insert(["message": text, "userID": user._id])
        }
    }

    func processCommand(_ cmd: String, ws: WebSocket)
    {
        print("Command: \(String(String(cmd.split(separator: " ")[0])))", terminator: "")
        print("next print")
        
        let hpf = cmd.hasPrefix(":update")
        let hsf = cmd.hasSuffix(":update")

        print("cmdstart\(cmd)cmdend")
        

        print("Command starts with \(hpf)")
        print("Command end swith \(hsf)")
        
        
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
                jsonText += "\"\(key)\": \"\(value)\","
            }
            jsonText += "},"
        }
        jsonText += "]"
        return jsonText
    }

    func onClose()
    {
        print("Connection closed")
        
    }

}