// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MotionLibrary",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        // The effects themselves. This is what apps depend on.
        .library(name: "MotionLibrary", targets: ["MotionLibrary"]),
        // Optional browser UI: a filterable gallery of every effect with live
        // previews, usage snippets and copyable AI prompts.
        .library(name: "MotionGallery", targets: ["MotionGallery"]),
    ],
    targets: [
        .target(name: "MotionLibrary"),
        .target(name: "MotionGallery", dependencies: ["MotionLibrary"]),
    ]
)
