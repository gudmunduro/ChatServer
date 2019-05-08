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
        .package(url: "https://github.com/OpenKitten/MongoKitten", from: "5.0.0"),

        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),

    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "MongoKitten", "Leaf"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

