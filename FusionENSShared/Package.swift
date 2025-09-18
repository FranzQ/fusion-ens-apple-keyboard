// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FusionENSShared",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FusionENSShared",
            targets: ["FusionENSShared"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0")
    ],
    targets: [
        .target(
            name: "FusionENSShared",
            dependencies: ["Alamofire"]
        ),
    ]
)
