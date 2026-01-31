// swift-tools-version: 5.9
// This file is for reference - add these dependencies via Xcode's SPM interface

/*
 DEPENDENCIES TO ADD IN XCODE:

 1. Firebase iOS SDK
    URL: https://github.com/firebase/firebase-ios-sdk
    Version: 10.0.0 or later
    Products to add:
    - FirebaseAuth
    - FirebaseFirestore
    - FirebaseStorage
    - FirebaseMessaging

 2. Kingfisher
    URL: https://github.com/onevcat/Kingfisher
    Version: 7.0.0 or later
    Products to add:
    - Kingfisher

 HOW TO ADD IN XCODE:
 1. Open Couply.xcodeproj
 2. Select the project in the navigator
 3. Select the Couply target
 4. Go to "Package Dependencies" tab
 5. Click "+" button
 6. Enter the package URL
 7. Select the products you need
 8. Click "Add Package"

 CAPABILITIES TO ENABLE:
 1. Push Notifications
 2. Background Modes > Remote notifications
 3. App Groups (for widget)

 */

import PackageDescription

let package = Package(
    name: "Couply",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "Couply",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "Kingfisher", package: "Kingfisher")
            ]
        )
    ]
)
