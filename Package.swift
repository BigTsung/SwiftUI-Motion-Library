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
        // Optional Metal shader effects (water ripple, pixellate, CRT…).
        // Separate so MotionLibrary builds without the Metal Toolchain, which
        // Xcode 26+ downloads on demand (Settings → Components).
        .library(name: "MotionShaders", targets: ["MotionShaders"]),
        // Optional browser UI: a filterable gallery of every effect with live
        // previews, usage snippets and copyable AI prompts.
        .library(name: "MotionGallery", targets: ["MotionGallery"]),
    ],
    targets: [
        .target(name: "MotionLibrary"),
        .target(name: "MotionShaders", resources: [.process("Shaders")]),
        .target(name: "MotionGallery", dependencies: ["MotionLibrary", "MotionShaders"]),
    ]
)
