import SwiftUI

/// A neon tube: a white-hot core with layered coloured glow. With `flicker`
/// on, it stutters on like a tube warming up, then glitches now and again.
struct NeonModifier: ViewModifier {
    var color: Color
    var flicker: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        // Reduce Motion: a steady glow (flashing can also be uncomfortable).
        if flicker && !reduceMotion {
            TimelineView(.animation) { timeline in
                let level = Self.brightness(at: timeline.date.timeIntervalSinceReferenceDate)
                glow(content, level: level)
            }
        } else {
            glow(content, level: 1)
        }
    }

    private func glow(_ content: Content, level: Double) -> some View {
        content
            // A white-hot core when lit; the bare coloured glass when it drops out.
            .foregroundStyle(level > 0.55 ? Color.white : color.opacity(0.55))
            .shadow(color: color.opacity(level), radius: 2)
            .shadow(color: color.opacity(0.9 * level), radius: 8)
            .shadow(color: color.opacity(0.7 * level), radius: 18)
            .opacity(0.35 + 0.65 * level)
    }

    /// 1 = fully lit, lower = dimmed. A 6 s cycle: a stuttering switch-on,
    /// a steady stretch, then a short double glitch.
    static func brightness(at time: Double) -> Double {
        let t = time.truncatingRemainder(dividingBy: 6)
        let dips: [(start: Double, end: Double, level: Double)] = [
            (0.00, 0.08, 0.1), (0.14, 0.18, 0.2), (0.26, 0.30, 0.15), (0.38, 0.40, 0.5),
            (4.20, 4.24, 0.3), (4.30, 4.36, 0.15), (4.42, 4.45, 0.6),
        ]
        for dip in dips where t >= dip.start && t < dip.end {
            return dip.level
        }
        // A barely visible hum keeps the steady part alive.
        return 0.94 + 0.06 * sin(time * 40)
    }
}

public extension View {
    /// Turns text or symbols into a glowing neon sign.
    ///
    /// ```swift
    /// Text("OPEN")
    ///     .font(.system(size: 48, weight: .bold, design: .rounded))
    ///     .neon(color: .pink)
    /// ```
    ///
    /// - Parameters:
    ///   - color: The colour of the glow.
    ///   - flicker: Stutter on and glitch now and again, like a real tube.
    func neon(color: Color = .pink, flicker: Bool = true) -> some View {
        modifier(NeonModifier(color: color, flicker: flicker))
    }
}

#Preview {
    VStack(spacing: 24) {
        Text("OPEN").font(.system(size: 52, weight: .bold, design: .rounded)).neon()
        Image(systemName: "bolt.fill").font(.system(size: 40)).neon(color: .cyan, flicker: false)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(white: 0.08))
}
