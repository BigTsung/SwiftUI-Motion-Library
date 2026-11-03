import SwiftUI

/// What kind of UI element an effect is applied to.
/// Mirrors the "component" axis of the original web Motion Library.
public enum MotionComponent: String, CaseIterable, Identifiable, Sendable {
    case text
    case button
    case card
    case shape
    case background
    case number
    case particle
    case transition
    case shader

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .text: "Text"
        case .button: "Button"
        case .card: "Card & Group"
        case .shape: "Shape"
        case .background: "Background"
        case .number: "Number"
        case .particle: "Particle & 3D"
        case .transition: "Transition"
        case .shader: "Shader"
        }
    }

    public var symbol: String {
        switch self {
        case .text: "textformat"
        case .button: "button.horizontal.top.press"
        case .card: "rectangle.stack"
        case .shape: "circle.hexagongrid"
        case .background: "sparkles.rectangle.stack"
        case .number: "number"
        case .particle: "cube.transparent"
        case .transition: "square.on.square.dashed"
        case .shader: "camera.filters"
        }
    }
}

/// When an effect plays. The "timing" axis of the library.
public enum MotionTrigger: String, CaseIterable, Identifiable, Sendable {
    case appear
    case tap
    case press
    case drag
    case hover
    case scroll
    case change
    case loop

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .appear: "Appear"
        case .tap: "Tap"
        case .press: "Press"
        case .drag: "Drag"
        case .hover: "Hover"
        case .scroll: "Scroll"
        case .change: "Value change"
        case .loop: "Loop"
        }
    }

    public var symbol: String {
        switch self {
        case .appear: "eye"
        case .tap: "hand.tap"
        case .press: "hand.point.down"
        case .drag: "hand.draw"
        case .hover: "cursorarrow.motionlines"
        case .scroll: "arrow.up.and.down"
        case .change: "arrow.triangle.2.circlepath"
        case .loop: "repeat"
        }
    }
}

/// The oldest OS versions an effect runs on.
public enum MotionRequirement: String, CaseIterable, Sendable {
    /// iOS 17, macOS 14, visionOS 1: the package's deployment targets.
    case ios17
    /// iOS 18, macOS 15, visionOS 2. The API is marked `@available` accordingly.
    case ios18

    public var title: String {
        switch self {
        case .ios17: "iOS 17+"
        case .ios18: "iOS 18+"
        }
    }

    /// Every platform version, e.g. "iOS 18+ · macOS 15+ · visionOS 2+".
    public var platforms: String {
        switch self {
        case .ios17: "iOS 17+ · macOS 14+ · visionOS 1+"
        case .ios18: "iOS 18+ · macOS 15+ · visionOS 2+"
        }
    }
}

/// One entry in the catalog: metadata + a live demo.
public struct MotionEffect: Identifiable {
    public let id: String
    public let name: String
    public let summary: String
    public let component: MotionComponent
    public let triggers: [MotionTrigger]
    /// The oldest OS versions the effect supports.
    public let requirement: MotionRequirement
    /// Copy-paste code showing how to use the effect from `MotionLibrary`.
    public let usage: String
    /// A description of the look and the technique, written so it can be
    /// pasted into an AI assistant to recreate or adapt the effect.
    public let prompt: String
    /// Path of the source file relative to `Sources/MotionLibrary`, or to
    /// `Sources/` for files in another module (`MotionShaders/…`).
    public let sourceFile: String

    /// The source file's path from the repository root.
    public var sourcePath: String {
        sourceFile.hasPrefix("MotionShaders/") ? "Sources/\(sourceFile)" : "Sources/MotionLibrary/\(sourceFile)"
    }

    /// The Metal shader that goes with a `MotionShaders` effect, from the
    /// repository root (`Sources/MotionShaders/Shaders/<Name>.metal`).
    public var shaderPath: String? {
        guard sourceFile.hasPrefix("MotionShaders/") else { return nil }
        let name = (sourceFile as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: ".metal")
        return "Sources/MotionShaders/Shaders/\(name)"
    }
    /// The public API in one line, e.g. `.shimmer()` or `PulseRings()`.
    public let api: String
    private let makeDemo: @MainActor () -> AnyView

    public init<Demo: View>(
        id: String,
        name: String,
        summary: String,
        component: MotionComponent,
        triggers: [MotionTrigger],
        requirement: MotionRequirement = .ios17,
        sourceFile: String,
        api: String = "",
        usage: String,
        prompt: String,
        @ViewBuilder demo: @escaping @MainActor () -> Demo
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.component = component
        self.triggers = triggers
        self.requirement = requirement
        self.sourceFile = sourceFile
        self.api = api
        self.usage = usage
        self.prompt = prompt
        self.makeDemo = { AnyView(demo()) }
    }

    @MainActor
    public func demo() -> AnyView { makeDemo() }
}
