import SwiftUI

/// A slanted glint of light that sweeps across the view once, either every
/// time `trigger` changes or on a fixed interval.
struct ShineModifier<Trigger: Equatable>: ViewModifier {
    var trigger: Trigger
    var color: Color
    var duration: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        // Reduce Motion: no sweep.
        let enabled = !reduceMotion
        let color = color
        return content
            .keyframeAnimator(initialValue: 0.0, trigger: trigger) { view, progress in
                view.overlay {
                    if enabled {
                        ShineBand(progress: progress, color: color).mask { view }
                    }
                }
            } keyframes: { _ in
                // 0 and 1 are both off the view, so the band is hidden at rest.
                CubicKeyframe(1, duration: duration)
            }
    }
}

/// Repeats the glint every `interval` seconds.
struct LoopingShineModifier: ViewModifier {
    var interval: Double
    var color: Color
    var duration: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.overlay {
            if !reduceMotion {
                TimelineView(.animation) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let phase = time.truncatingRemainder(dividingBy: max(interval, duration))
                    ShineBand(progress: min(1, phase / duration), color: color)
                }
                .mask { content }
            }
        }
    }
}

/// The band itself: a skewed white gradient that travels left to right as
/// `progress` goes from 0 to 1.
private struct ShineBand: View {
    var progress: Double
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let band = max(24, width * 0.3)
            LinearGradient(colors: [.clear, color, .clear], startPoint: .leading, endPoint: .trailing)
                .frame(width: band, height: geometry.size.height * 2)
                .rotationEffect(.degrees(20))
                .offset(x: -band * 1.5 + (width + band * 3) * progress, y: -geometry.size.height / 2)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

public extension View {
    /// Sweeps a glint of light across the view every time `trigger` changes.
    ///
    /// ```swift
    /// Button("Upgrade") { purchases += 1 }
    ///     .buttonStyle(.borderedProminent)
    ///     .shine(trigger: purchases)
    /// ```
    func shine<Trigger: Equatable>(
        trigger: Trigger,
        color: Color = .white.opacity(0.7),
        duration: Double = 0.75
    ) -> some View {
        modifier(ShineModifier(trigger: trigger, color: color, duration: duration))
    }

    /// Sweeps a glint of light across the view every `interval` seconds.
    ///
    /// ```swift
    /// PremiumBadge()
    ///     .shine(every: 3)
    /// ```
    func shine(
        every interval: Double,
        color: Color = .white.opacity(0.7),
        duration: Double = 0.75
    ) -> some View {
        modifier(LoopingShineModifier(interval: interval, color: color, duration: duration))
    }
}

#Preview {
    Text("Go Premium")
        .font(.headline)
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Capsule().fill(Color.orange.gradient))
        .shine(every: 2)
        .padding()
}
