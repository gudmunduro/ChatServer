// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ChatServer",
    products: [
        .library(name: "ChatServer", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // MongoDB
        .package(url: "https://github.com/mongodb/mongo-swift-driver.git", from: "0.0.9")

    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "MongoSwift"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

