import Vapor

/// Register your application's routes here.
public func routes(_ router: Router, _ wssRouter: NIOWebSocketServer) throws {
    router.get { req in
        return "Main site"
    }

    let userController = UserController()

    router.post("user", "create", use: userController.create)
    router.get("user", "login", use: userController.login)
    router.get("user", "all", use: userController.allUsers)

    let chatController = ChatController()

    wssRouter.get("connect", use: chatController.connect)

}
