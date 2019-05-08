import Vapor

final class ChatController {

    let chatRoom = ChatRoom()

    func test(_ ws: WebSocket, _ req: Request) {
        ws.onText { ws, text in
            ws.send(text.reversed())
        }
    }

    func connect(_ ws: WebSocket, _ req: Request) throws {
        guard let token = req.query[String.self, at: "token"]?
                            .replacingOccurrences(of: " ", with: "+") else {
            throw Abort(.badRequest, reason: "Auth failure")
        }
        
        let db = try req.mongoDB()
        try req.requireAuthenticated(db, customToken: token).whenSuccess { user in            
            // _ = ChatHandler(ws: ws, user: user, db: db)
            self.chatRoom.addUser(ws: ws, user: user, db: db)
        }
    }

    

}