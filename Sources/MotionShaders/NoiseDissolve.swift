import SwiftUI

/// Burns the view away in organic noise blotches with a glowing edge, like
/// paper catching fire. `progress` is animatable, and there's a matching
/// transition. Rendered with a Metal `colorEffect`
/// (`Shaders/NoiseDissolve.metal`).
struct NoiseDissolveModifier: ViewModifier, Animatable {
    var progress: Double
    var scale: Double
    var edge: Color

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.colorEffect(
            motionShaders.motionDissolve(.float(progress), .float(scale), .color(edge)),
            isEnabled: progress > 0
        )
    }
}

/// Burns the view away on removal and un-burns it on insertion.
public struct NoiseDissolveTransition: Transition {
    public var edge: Color

    public init(edge: Color = .orange) {
        self.edge = edge
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        NoiseDissolveBody(content: content, phase: phase, edge: edge)
    }
}

private struct NoiseDissolveBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase
    let edge: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            // Reduce Motion: a plain fade.
            content.opacity(phase.isIdentity ? 1 : 0)
        } else {
            content.modifier(NoiseDissolveModifier(progress: phase.isIdentity ? 0 : 1, scale: 18, edge: edge))
        }
    }
}

public extension View {
    /// Dissolves the view in noise: 0 shows it all, 1 hides it all.
    /// Animate `progress` to burn it away.
    ///
    /// ```swift
    /// Card()
    ///     .noiseDissolve(isDeleting ? 1 : 0)
    ///     .animation(.easeIn(duration: 1), value: isDeleting)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameters:
    ///   - progress: 0…1.
    ///   - scale: Size of the noise blotches, in points.
    ///   - edge: Colour of the burning edge.
    func noiseDissolve(_ progress: Double, scale: Double = 18, edge: Color = .orange) -> some View {
        modifier(NoiseDissolveModifier(progress: progress, scale: scale, edge: edge))
    }
}

public extension Transition where Self == NoiseDissolveTransition {
    /// Burns the view away in glowing noise (and back in on insertion).
    ///
    /// ```swift
    /// if !isDeleted {
    ///     NoteCard().transition(.noiseDissolve)
    /// }
    /// ```
    static var noiseDissolve: NoiseDissolveTransition { NoiseDissolveTransition() }

    /// Burns the view away with an `edge`-coloured glow.
    static func noiseDissolve(edge: Color) -> NoiseDissolveTransition { NoiseDissolveTransition(edge: edge) }
}

#Preview {
    struct Demo: View {
        @State private var burnt = false
        var body: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.indigo.gradient)
                .frame(width: 220, height: 150)
                .noiseDissolve(burnt ? 1 : 0)
                .onTapGesture { withAnimation(.easeInOut(duration: 1.2)) { burnt.toggle() } }
        }
    }
    return Demo()
}
