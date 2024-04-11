// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Tuist-Pokedex",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMajor(from: "1.16.0")),
        .package(url: "https://github.com/kean/Nuke", .upToNextMajor(from: "12.1.6"))
    ]
)
