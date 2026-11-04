import SwiftUI

/// Crumbles the view into grains of sand that blow away on the wind, the
/// grains nearest the wind's source going first. `progress` is animatable,
/// and there's a matching transition. Rendered with a Metal `layerEffect`
/// (`Shaders/Disintegrate.metal`).
struct DisintegrateModifier: ViewModifier, Animatable {
    var progress: Double
    var wind: CGVector
    var grain: Double

    nonisolated var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let progress = Float(progress), grain = Float(max(1, grain))
        let wind = CGPoint(x: wind.dx, y: wind.dy)
        let reach = CGSize(width: abs(wind.x) + Double(grain) * 6, height: abs(wind.y) + Double(grain) * 6)
        return content.visualEffect { effect, proxy in
            effect.layerEffect(
                motionShaders.motionDisintegrate(.float2(proxy.size), .float(progress), .float(grain), .float2(wind)),
                maxSampleOffset: reach,
                isEnabled: progress > 0
            )
        }
    }
}

/// Blows the view away as sand on removal and gathers it back on insertion.
public struct DisintegrateTransition: Transition {
    public var wind: CGVector

    public init(wind: CGVector = CGVector(dx: 140, dy: -60)) {
        self.wind = wind
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        DisintegrateBody(content: content, phase: phase, wind: wind)
    }
}

private struct DisintegrateBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase
    let wind: CGVector

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            content.opacity(phase.isIdentity ? 1 : 0)
        } else {
            content.modifier(DisintegrateModifier(progress: phase.isIdentity ? 0 : 1, wind: wind, grain: 2))
        }
    }
}

public extension View {
    /// Crumbles the view into blowing sand: 0 shows it whole, 1 has blown
    /// it all away. Animate `progress` to make it go.
    ///
    /// ```swift
    /// Avatar()
    ///     .disintegrate(isGone ? 1 : 0)
    ///     .animation(.easeIn(duration: 1.6), value: isGone)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameters:
    ///   - progress: 0…1.
    ///   - wind: Where the grains blow, and how far, in points.
    ///   - grain: Size of a grain, in points.
    func disintegrate(_ progress: Double, wind: CGVector = CGVector(dx: 140, dy: -60), grain: Double = 2) -> some View {
        modifier(DisintegrateModifier(progress: progress, wind: wind, grain: grain))
    }
}

public extension Transition where Self == DisintegrateTransition {
    /// Blows the view away as sand (and gathers it back in on insertion).
    ///
    /// ```swift
    /// if !isDeleted {
    ///     MessageRow().transition(.disintegrate)
    /// }
    /// ```
    static var disintegrate: DisintegrateTransition { DisintegrateTransition() }

    /// Blows the view away as sand along `wind`, in points.
    static func disintegrate(wind: CGVector) -> DisintegrateTransition { DisintegrateTransition(wind: wind) }
}

#Preview {
    struct Demo: View {
        @State private var gone = false
        var body: some View {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.orange.gradient)
                .overlay(Image(systemName: "person.fill").font(.system(size: 60)).foregroundStyle(.white))
                .frame(width: 160, height: 160)
                .disintegrate(gone ? 1 : 0)
                .onTapGesture { withAnimation(.easeIn(duration: 1.6)) { gone.toggle() } }
        }
    }
    return Demo()
}
