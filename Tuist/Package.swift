// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tuist-Pokedex",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMajor(from: "1.16.0"))
    ]
)
