import SwiftUI

/// A set of looping activity indicators. Pick a style; size it with `.frame`.
public struct MotionLoader: View {
    /// The look of the loader.
    public enum Style: String, CaseIterable, Sendable {
        /// An arc that spins while its length breathes.
        case spinner
        /// Three dots hopping in sequence.
        case dots
        /// Equaliser bars rising and falling in a wave.
        case bars
        /// Two dots orbiting each other.
        case orbit
        /// A ring that pulses outward.
        case pulse
    }

    private let style: Style
    private let color: Color
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - style: Which loader to draw.
    ///   - color: Fill or stroke colour.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    public init(_ style: Style = .spinner, color: Color = .accentColor, speed: Double = 1) {
        self.style = style
        self.color = color
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: speed == 0)) { timeline in
            // Reduce Motion: a slow opacity breathe instead of movement.
            let time = timeline.date.timeIntervalSinceReferenceDate * speed
            GeometryReader { geometry in
                let side = min(geometry.size.width, geometry.size.height)
                Group {
                    if reduceMotion {
                        Circle()
                            .fill(color)
                            .frame(width: side * 0.4, height: side * 0.4)
                            .opacity(0.4 + 0.4 * (0.5 + 0.5 * sin(time * 2)))
                    } else {
                        loader(time: time, side: side)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("Loading")
        .accessibilityAddTraits(.updatesFrequently)
    }

    @ViewBuilder
    private func loader(time: Double, side: CGFloat) -> some View {
        switch style {
        case .spinner:
            let breathe = 0.5 + 0.5 * sin(time * 3)
            Circle()
                .trim(from: 0, to: 0.15 + 0.6 * breathe)
                .stroke(color, style: StrokeStyle(lineWidth: side * 0.1, lineCap: .round))
                .rotationEffect(.radians(time * 5))
                .padding(side * 0.05)

        case .dots:
            HStack(spacing: side * 0.1) {
                ForEach(0..<3, id: \.self) { index in
                    let hop = max(0, sin(time * 6 - Double(index) * 0.9))
                    Circle()
                        .fill(color)
                        .frame(width: side * 0.22, height: side * 0.22)
                        .offset(y: -side * 0.25 * hop)
                        .opacity(0.5 + 0.5 * hop)
                }
            }
            .offset(y: side * 0.1)

        case .bars:
            HStack(alignment: .center, spacing: side * 0.07) {
                ForEach(0..<5, id: \.self) { index in
                    let level = 0.5 + 0.5 * sin(time * 5 - Double(index) * 0.7)
                    Capsule()
                        .fill(color)
                        .frame(width: side * 0.12, height: side * (0.25 + 0.65 * level))
                }
            }

        case .orbit:
            ZStack {
                ForEach(0..<2, id: \.self) { index in
                    let angle = time * 4 + Double(index) * .pi
                    let depth = 0.5 + 0.5 * sin(angle)
                    Circle()
                        .fill(color)
                        .frame(width: side * 0.3, height: side * 0.3)
                        .scaleEffect(0.7 + 0.3 * depth)
                        .opacity(0.6 + 0.4 * depth)
                        .offset(x: cos(angle) * side * 0.3)
                        .zIndex(depth)
                }
            }

        case .pulse:
            ZStack {
                ForEach(0..<2, id: \.self) { index in
                    let phase = (time * 0.8 + Double(index) * 0.5).truncatingRemainder(dividingBy: 1)
                    Circle()
                        .stroke(color, lineWidth: side * 0.06)
                        .scaleEffect(0.2 + 0.8 * phase)
                        .opacity(1 - phase)
                }
                Circle()
                    .fill(color)
                    .frame(width: side * 0.2, height: side * 0.2)
            }
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        ForEach(MotionLoader.Style.allCases, id: \.self) { style in
            MotionLoader(style)
                .frame(width: 44, height: 44)
        }
    }
    .padding()
}
