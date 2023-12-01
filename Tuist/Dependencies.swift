import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(url: "https://github.com/pointfreeco/swiftui-navigation",
                requirement: .upToNextMajor(from: "1.0.0")),
        .remote(url: "https://github.com/pointfreeco/swift-snapshot-testing",
                requirement: .upToNextMinor(from: "1.13.0")),
        .remote(url: "https://github.com/kean/Nuke",
                requirement: .upToNextMajor(from: "12.1.6"))
    ],
    platforms: [.iOS]
)
