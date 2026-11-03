import SwiftUI

/// Digital glitch: every couple of seconds the view splits into red and cyan
/// copies, and horizontal slices jump sideways for a fraction of a second.
/// Works on any view (text, images, logos).
struct GlitchModifier: ViewModifier {
    var isActive: Bool
    var intensity: CGFloat
    var interval: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        // Reduce Motion: no glitching at all.
        let running = isActive && !reduceMotion
        TimelineView(.animation(minimumInterval: 1.0 / 24, paused: !running)) { timeline in
            let state = running
                ? GlitchState(time: timeline.date.timeIntervalSinceReferenceDate, interval: interval)
                : .calm
            content
                // Colour fringes: solid cyan and red silhouettes (brightness 1
                // turns any colour white first) to the left and right.
                .background {
                    ZStack {
                        content.brightness(1).colorMultiply(.cyan).offset(x: -state.split * intensity)
                        content.brightness(1).colorMultiply(.red).offset(x: state.split * intensity)
                    }
                    .opacity(state.split == 0 ? 0 : 0.85)
                    .accessibilityHidden(true)
                }
                // A slice of the view displaced sideways.
                .overlay {
                    GeometryReader { geometry in
                        let height = geometry.size.height
                        content
                            .offset(x: state.sliceOffset * intensity)
                            .mask {
                                Rectangle()
                                    .frame(height: height * state.sliceHeight)
                                    .offset(y: height * (state.sliceY - 0.5))
                            }
                            .frame(width: geometry.size.width, height: height)
                    }
                    .opacity(state.sliceOffset == 0 ? 0 : 1)
                    .accessibilityHidden(true)
                }
                .offset(x: state.jitter * intensity)
        }
    }
}

/// The glitch values for one moment, derived from the clock so the effect
/// needs no state.
private struct GlitchState {
    var split: CGFloat = 0
    var sliceOffset: CGFloat = 0
    var sliceY: CGFloat = 0.5
    var sliceHeight: CGFloat = 0.2
    var jitter: CGFloat = 0

    static let calm = GlitchState()

    init() {}

    init(time: Double, interval: Double) {
        let cycle = max(0.4, interval)
        let phase = time.truncatingRemainder(dividingBy: cycle)
        // Glitch for the first 0.35 s of every cycle.
        guard phase < 0.35 else { return }
        // Change the random values 24 times a second.
        let step = Int(time * 24)
        split = 2 + 4 * Self.noise(step, 1)
        if Self.noise(step, 2) > 0.35 {
            sliceOffset = (Self.noise(step, 3) - 0.5) * 24
            sliceY = 0.15 + 0.7 * Self.noise(step, 4)
            sliceHeight = 0.1 + 0.25 * Self.noise(step, 5)
        }
        jitter = (Self.noise(step, 6) - 0.5) * 3
    }

    /// Cheap hash to 0..<1.
    static func noise(_ step: Int, _ salt: Int) -> CGFloat {
        var x = UInt64(bitPattern: Int64(step &* 7919 &+ salt &* 104_729))
        x = (x ^ (x >> 33)) &* 0xff51_afd7_ed55_8ccd
        x = (x ^ (x >> 33)) &* 0xc4ce_b9fe_1a85_ec53
        x ^= x >> 33
        return CGFloat(x % 10_000) / 10_000
    }
}

public extension View {
    /// Makes the view glitch every `interval` seconds: an RGB split, displaced
    /// slices and a little jitter.
    ///
    /// ```swift
    /// Text("SYSTEM FAILURE")
    ///     .font(.title.monospaced().bold())
    ///     .glitch()
    /// ```
    ///
    /// - Parameters:
    ///   - isActive: Turns the effect on and off.
    ///   - intensity: Multiplies every offset (1 = default strength).
    ///   - interval: Seconds between glitch bursts.
    func glitch(isActive: Bool = true, intensity: CGFloat = 1, interval: Double = 2) -> some View {
        modifier(GlitchModifier(isActive: isActive, intensity: intensity, interval: interval))
    }
}

#Preview {
    Text("SYSTEM FAILURE")
        .font(.largeTitle.monospaced().bold())
        .glitch()
        .padding()
}
