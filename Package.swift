// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PeekBoard",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "6.29.3"),
        .package(url: "https://github.com/soffes/HotKey.git", exact: "0.2.1"),
    ],
    targets: [
        .executableTarget(
            name: "PeekBoard",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "HotKey", package: "HotKey"),
            ],
            path: "PeekBoard",
            exclude: [
                "Resources/Assets.xcassets",
                "Info.plist",
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        ),
    ]
)
