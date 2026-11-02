// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CleanMode",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "CleanMode", path: "Sources/CleanMode")
    ]
)
