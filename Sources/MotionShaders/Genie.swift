import SwiftUI

/// The "genie" minimise: the view pinches towards a point on its bottom edge
/// and pours down into it. `progress` is animatable, and there's a matching
/// transition. Rendered with a Metal `distortionEffect`
/// (`Shaders/Genie.metal`).
struct GenieModifier: ViewModifier, Animatable {
    var progress: Double
    var target: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let progress = Float(progress), target = Float(target)
        return content.visualEffect { effect, proxy in
            effect.distortionEffect(
                motionShaders.motionGenie(.float2(proxy.size), .float(progress), .float(target)),
                maxSampleOffset: proxy.size,
                isEnabled: progress > 0
            )
        }
    }
}

/// Sucks the view into a point below it on removal, and pours it back out on
/// insertion.
public struct GenieTransition: Transition {
    public var target: Double

    public init(target: Double = 0.5) {
        self.target = target
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        GenieBody(content: content, phase: phase, target: target)
    }
}

private struct GenieBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase
    let target: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            content.opacity(phase.isIdentity ? 1 : 0)
        } else {
            content.modifier(GenieModifier(progress: phase.isIdentity ? 0 : 1, target: target))
        }
    }
}

public extension View {
    /// Pours the view into a point on its bottom edge: 0 shows it, 1 has it
    /// fully minimised.
    ///
    /// ```swift
    /// Window()
    ///     .genie(isMinimised ? 1 : 0, toward: 0.8)
    ///     .animation(.easeIn(duration: 0.6), value: isMinimised)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameters:
    ///   - progress: 0…1.
    ///   - target: Where along the bottom edge it goes, 0 (left) to 1 (right).
    func genie(_ progress: Double, toward target: Double = 0.5) -> some View {
        modifier(GenieModifier(progress: progress, target: min(1, max(0, target))))
    }
}

public extension Transition where Self == GenieTransition {
    /// Minimises the view into the middle of its bottom edge, genie style.
    ///
    /// ```swift
    /// if isOpen {
    ///     Panel().transition(.genie)
    /// }
    /// ```
    static var genie: GenieTransition { GenieTransition() }

    /// Minimises the view into a point on its bottom edge, 0 (left) to 1 (right).
    static func genie(toward target: Double) -> GenieTransition { GenieTransition(target: min(1, max(0, target))) }
}

#Preview {
    struct Demo: View {
        @State private var minimised = false
        var body: some View {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.blue.gradient)
                .overlay(Text("Window").font(.title.bold()).foregroundStyle(.white))
                .frame(width: 220, height: 150)
                .genie(minimised ? 1 : 0, toward: 0.8)
                .frame(height: 260, alignment: .top)
                .onTapGesture { withAnimation(.easeInOut(duration: 0.8)) { minimised.toggle() } }
        }
    }
    return Demo()
}
