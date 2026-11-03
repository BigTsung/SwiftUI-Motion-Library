import SwiftUI

/// Concentric rings that continuously expand and fade, like a radar or a
/// "live" indicator. Place it behind an icon or avatar.
///
/// ```swift
/// ZStack {
///     PulseRings(color: .green)
///         .frame(width: 120, height: 120)
///     Circle().fill(.green).frame(width: 24, height: 24)
/// }
/// ```
public struct PulseRings: View {
    private let color: Color
    private let count: Int
    private let duration: Double
    private let lineWidth: CGFloat

    public init(color: Color = .accentColor, count: Int = 3, duration: Double = 2, lineWidth: CGFloat = 2) {
        self.color = color
        self.count = max(1, count)
        self.duration = duration
        self.lineWidth = lineWidth
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    ring(progress: progress(time: time, index: index))
                }
            }
        }
        .accessibilityHidden(true)
    }

    private func progress(time: TimeInterval, index: Int) -> Double {
        let offset = Double(index) / Double(count)
        return (time / duration + offset).truncatingRemainder(dividingBy: 1)
    }

    private func ring(progress: Double) -> some View {
        Circle()
            .stroke(color, lineWidth: lineWidth)
            .scaleEffect(0.2 + progress * 0.8)
            .opacity(1 - progress)
    }
}

#Preview {
    ZStack {
        PulseRings(color: .green)
            .frame(width: 160, height: 160)
        Circle()
            .fill(.green)
            .frame(width: 28, height: 28)
    }
}
