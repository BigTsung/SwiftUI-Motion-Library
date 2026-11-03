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

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .text: "Text"
        case .button: "Button"
        case .card: "Card & Group"
        case .shape: "Shape"
        case .background: "Background"
        case .number: "Number"
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
        }
    }
}

/// When an effect plays. The "timing" axis of the library.
public enum MotionTrigger: String, CaseIterable, Identifiable, Sendable {
    case appear
    case tap
    case press
    case drag
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
        case .scroll: "arrow.up.and.down"
        case .change: "arrow.triangle.2.circlepath"
        case .loop: "repeat"
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
    /// Copy-paste code showing how to use the effect from `MotionLibrary`.
    public let usage: String
    /// A description of the look and the technique, written so it can be
    /// pasted into an AI assistant to recreate or adapt the effect.
    public let prompt: String
    /// Name of the source file in `Sources/MotionLibrary`, for "view source".
    public let sourceFile: String
    private let makeDemo: @MainActor () -> AnyView

    public init<Demo: View>(
        id: String,
        name: String,
        summary: String,
        component: MotionComponent,
        triggers: [MotionTrigger],
        sourceFile: String,
        usage: String,
        prompt: String,
        @ViewBuilder demo: @escaping @MainActor () -> Demo
    ) {
        self.id = id
        self.name = name
        self.summary = summary
        self.component = component
        self.triggers = triggers
        self.sourceFile = sourceFile
        self.usage = usage
        self.prompt = prompt
        self.makeDemo = { AnyView(demo()) }
    }

    @MainActor
    public func demo() -> AnyView { makeDemo() }
}
