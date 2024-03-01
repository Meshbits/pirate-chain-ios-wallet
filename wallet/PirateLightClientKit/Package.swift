// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PirateLightClientKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PirateLightClientKit",
            targets: ["PirateLightClientKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.14.0"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1"),
        .package(url: "https://github.com/piratenetwork/pirate-light-client-ffi.git", revision: "b07e6fb619a8f0eadd344f4e0d3e81d8a7a0a33a")
    ],
    targets: [
        .target(
            name: "PirateLightClientKit",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "libpiratelc", package: "pirate-light-client-ffi")
            ],
            exclude: [
                "Modules/Service/GRPC/ProtoBuf/proto/compact_formats.proto",
                "Modules/Service/GRPC/ProtoBuf/proto/service.proto",
                "Error/Sourcery/"
            ],
            resources: [
                .copy("Resources/piratesaplingtree-checkpoints")
            ]
        ),
        .target(
            name: "TestUtils",
            dependencies: ["PirateLightClientKit"],
            path: "Tests/TestUtils",
            exclude: [
                "proto/darkside.proto",
                "Sourcery/AutoMockable.stencil",
                "Sourcery/generateMocks.sh"
            ],
            resources: [
                .copy("Resources/test_data.db"),
                .copy("Resources/cache.db"),
                .copy("Resources/darkside_caches.db"),
                .copy("Resources/darkside_data.db"),
                .copy("Resources/sandblasted_mainnet_block.json"),
                .copy("Resources/txBase64String.txt"),
                .copy("Resources/txFromAndroidSDK.txt"),
                .copy("Resources/integerOverflowJSON.json"),
                .copy("Resources/sapling-spend.params"),
                .copy("Resources/sapling-output.params")
            ]
        ),
        .testTarget(
            name: "OfflineTests",
            dependencies: ["PirateLightClientKit", "TestUtils"]
        ),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["PirateLightClientKit", "TestUtils"]
        ),
        .testTarget(
            name: "DarksideTests",
            dependencies: ["PirateLightClientKit", "TestUtils"]
        ),
        .testTarget(
            name: "AliasDarksideTests",
            dependencies: ["PirateLightClientKit", "TestUtils"],
            exclude: [
                "scripts/"
            ]
        ),
        .testTarget(
            name: "PerformanceTests",
            dependencies: ["PirateLightClientKit", "TestUtils"]
        )
    ]
)
