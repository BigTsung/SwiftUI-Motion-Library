import SwiftUI

/// The home-screen "edit mode" wiggle: a quick, slightly irregular rotation
/// and bob. Each view gets its own phase so a grid never moves in lockstep.
struct JiggleModifier: ViewModifier {
    var isActive: Bool
    var angle: Double

    @State private var phase = Double.random(in: 0..<1)
    @State private var rate = Double.random(in: 0.9..<1.1)
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        // Reduce Motion: stay still.
        let running = isActive && !reduceMotion
        TimelineView(.animation(paused: !running)) { timeline in
            let t = (timeline.date.timeIntervalSinceReferenceDate * rate + phase) * 2 * .pi * 3.6
            content
                .rotationEffect(.degrees(running ? sin(t) * angle : 0))
                .offset(y: running ? CGFloat(cos(t * 0.5)) * 0.8 : 0)
                .animation(.easeOut(duration: 0.15), value: running)
        }
    }
}

public extension View {
    /// Wiggles the view like an app icon in edit mode while `isActive` is true.
    ///
    /// ```swift
    /// ForEach(apps) { app in
    ///     AppIcon(app)
    ///         .jiggle(isActive: isEditing)
    /// }
    /// ```
    ///
    /// - Parameter angle: Peak rotation, in degrees.
    func jiggle(isActive: Bool = true, angle: Double = 2.5) -> some View {
        modifier(JiggleModifier(isActive: isActive, angle: angle))
    }
}

#Preview {
    HStack(spacing: 16) {
        ForEach([Color.blue, .green, .orange, .pink], id: \.self) { color in
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.gradient)
                .frame(width: 54, height: 54)
                .jiggle()
        }
    }
    .padding()
}
