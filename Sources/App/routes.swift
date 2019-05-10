import Vapor

/// Register your application's routes here.
public func routes(_ router: Router, _ wssRouter: NIOWebSocketServer) throws {

    let uiController = UIController()

    router.get(use: uiController.index)

    let userController = UserController()

    router.post("user", "create", use: userController.create)
    router.get("user", "login", use: userController.login)
    router.get("user", "test", use: userController.isLoggedIn)
    router.get("user", "all", use: userController.allUsers)

    let chatController = ChatController()

    wssRouter.get("connect", use: chatController.connect)

}
