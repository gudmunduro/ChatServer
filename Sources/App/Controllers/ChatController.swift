import Vapor

final class ChatController {

    func test(_ ws: WebSocket, _ req: Request) {
        ws.onText { ws, text in
            ws.send(text.reversed())
        }
    }

    func connect(_ ws: WebSocket, _ req: Request) throws {
        let db = try req.mongoDB()
        let token = try req.parameters.next(String.self)
        try req.requireAuthenticated(db, customToken: token).whenSuccess { user in            
            _ = ChatHandler(ws: ws, user: user, db: db)
        }
    }

    

}