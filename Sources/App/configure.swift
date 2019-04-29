import Vapor
import MongoKitten

extension MongoKitten.Database: Service {}

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    // try services.register(FluentSQLiteProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    let wssRouter = NIOWebSocketServer.default()
    try routes(router, wssRouter)
    services.register(router, as: Router.self)
    services.register(wssRouter, as: WebSocketServer.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    let connectionURI = "mongodb://localhost"
    services.register(MongoKitten.Database.self) { container in
        return try MongoKitten.Database.lazyConnect(connectionURI, on: container.eventLoop)
    }

    // Configure a SQLite database
    // let sqlite = try SQLiteDatabase(storage: .memory)

    // Register the configured SQLite database to the database config.
    // var databases = DatabasesConfig()
    // databases.add(database: sqlite, as: .sqlite)
    // services.register(databases)

    // Configure migrations
    // var migrations = MigrationConfig()
    // migrations.add(model: Todo.self, database: .sqlite)
    // services.register(migrations)
}
