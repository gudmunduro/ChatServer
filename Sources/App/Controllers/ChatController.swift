import Vapor

final class ChatController {

    func test(_ ws: WebSocket, _ req: Request) {
        ws.onText { ws, text in
            ws.send(text.reversed())
        }
    }

    func connect(_ ws: WebSocket, _ req: Request) throws {
        let db = try req.mongoDB()
        try req.requireAuthenticated(db).whenSuccess { user in            
            _ = ChatHandler(ws: ws, user: user, db: db)
        }
    }

    

}