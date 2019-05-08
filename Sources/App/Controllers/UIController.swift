import Vapor
import Leaf

final class UIController {

    func index(_ req: Request) throws -> Future<View>
    {
        return try req.view().render("chat")
    }

}