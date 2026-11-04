import SwiftUI

/// Twists the view around a point like water going down a drain.
/// `strength` is animatable. Rendered with a Metal `distortionEffect`
/// (`Shaders/Swirl.metal`).
struct SwirlModifier: ViewModifier, Animatable {
    var centre: CGPoint
    var radius: Double
    var strength: Double

    var animatableData: Double {
        get { strength }
        set { strength = newValue }
    }

    func body(content: Content) -> some View {
        content.distortionEffect(
            motionShaders.motionSwirl(.float2(centre), .float(radius), .float(strength)),
            maxSampleOffset: CGSize(width: radius, height: radius),
            isEnabled: abs(strength) > 0.001
        )
    }
}

/// Swirls wherever a finger drags, and untwists with a spring on release.
struct SwirlOnDragModifier: ViewModifier {
    var radius: Double
    var strength: Double

    @State private var centre: CGPoint = .zero
    @State private var amount: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .modifier(SwirlModifier(centre: centre, radius: radius, strength: amount))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !reduceMotion else { return }
                        centre = value.location
                        // Twist harder the further the finger travels.
                        let travel = hypot(value.translation.width, value.translation.height)
                        withAnimation(.interactiveSpring(duration: 0.3)) {
                            amount = strength * min(1, 0.35 + travel / 160)
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(duration: 0.8, bounce: 0.45)) { amount = 0 }
                    }
            )
    }
}

public extension View {
    /// Twists the view around `centre`. Animate `strength` to stir it.
    ///
    /// ```swift
    /// Image("latte")
    ///     .swirl(at: point, strength: isStirred ? 4 : 0)
    ///     .animation(.spring(duration: 1), value: isStirred)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameters:
    ///   - centre: Centre of the twist, in the view's coordinates.
    ///   - radius: Reach of the twist, in points.
    ///   - strength: Twist at the centre, in radians (negative turns the other way).
    func swirl(at centre: CGPoint, radius: Double = 110, strength: Double) -> some View {
        modifier(SwirlModifier(centre: centre, radius: radius, strength: strength))
    }

    /// Swirls the view under a dragging finger and springs back on release.
    ///
    /// ```swift
    /// Image("galaxy")
    ///     .swirlOnDrag()
    /// ```
    func swirlOnDrag(radius: Double = 110, strength: Double = 4) -> some View {
        modifier(SwirlOnDragModifier(radius: radius, strength: strength))
    }
}

#Preview {
    LinearGradient(colors: [.blue, .purple, .pink], startPoint: .top, endPoint: .bottom)
        .overlay(Text("SWIRL").font(.system(size: 50, weight: .black)).foregroundStyle(.white))
        .frame(width: 280, height: 200)
        .swirlOnDrag()
}
