import Vapor

final class ChatController {

    func test(_ ws: WebSocket, _ req: Request) {
        ws.onText { ws, text in
            ws.send(text.reversed())
        }
    }

}