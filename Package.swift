// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuthLibrarySPM",
    platforms: [.iOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AuthLibrarySPM",
            targets: ["AuthLibrarySPM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/aws-amplify/aws-sdk-ios-spm.git", from: "2.30.2"),
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "20.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AuthLibrarySPM",
            dependencies: [
                            .product(name: "AWSMobileClientXCF", package: "aws-sdk-ios-spm"),
//                            .product(name: "AWSMobileClient", package: "aws-sdk-ios-spm"),
                            .product(name: "AWSAuthCore", package: "aws-sdk-ios-spm"),
                            .product(name: "AWSAuthUI", package: "aws-sdk-ios-spm"),
                            .product(name: "AWSCognitoIdentityProviderASF", package: "aws-sdk-ios-spm"),
                            .product(name: "KeychainSwift", package: "Keychain-swift")
                        ],
                        path: "Sources"
        ),
        .testTarget(
            name: "AuthLibrarySPMTests",
            dependencies: ["AuthLibrarySPM"]
        ),
    ]
)
