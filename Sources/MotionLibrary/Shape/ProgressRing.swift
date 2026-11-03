import SwiftUI

/// A circular progress ring with a gradient stroke and rounded cap that
/// springs to each new value, with the percentage counting in the middle.
public struct ProgressRing<Label: View>: View {
    private let progress: Double
    private let lineWidth: CGFloat
    private let colors: [Color]
    private let label: Label

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - progress: 0…1.
    ///   - lineWidth: Ring thickness, in points.
    ///   - colors: Gradient along the ring, from start to end.
    ///   - label: What sits inside the ring.
    public init(
        progress: Double,
        lineWidth: CGFloat = 12,
        colors: [Color] = [.cyan, .blue, .purple],
        @ViewBuilder label: () -> Label
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.colors = colors
        self.label = label()
    }

    public var body: some View {
        let clamped = min(1, max(0, progress))
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(
                    AngularGradient(colors: colors, center: .center, startAngle: .degrees(0), endAngle: .degrees(360)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            label
        }
        .padding(lineWidth / 2)
        .animation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.6, dampingFraction: 0.75), value: clamped)
        .accessibilityElement(children: .ignore)
        .accessibilityValue(clamped.formatted(.percent.precision(.fractionLength(0))))
    }
}

public extension ProgressRing where Label == ProgressRingPercent {
    /// A ring with the percentage in the middle.
    ///
    /// ```swift
    /// ProgressRing(progress: uploaded)
    ///     .frame(width: 120, height: 120)
    /// ```
    init(progress: Double, lineWidth: CGFloat = 12, colors: [Color] = [.cyan, .blue, .purple]) {
        self.init(progress: progress, lineWidth: lineWidth, colors: colors) {
            ProgressRingPercent(progress: progress)
        }
    }
}

/// The default label: a percentage that rolls to each new value.
public struct ProgressRingPercent: View {
    let progress: Double

    public var body: some View {
        let value = min(1, max(0, progress))
        Text(value.formatted(.percent.precision(.fractionLength(0))))
            .font(.title2.bold().monospacedDigit())
            .contentTransition(.numericText(value: value))
    }
}

#Preview {
    struct Demo: View {
        @State private var progress = 0.35
        var body: some View {
            ProgressRing(progress: progress)
                .frame(width: 120, height: 120)
                .onTapGesture { progress = progress >= 1 ? 0.1 : progress + 0.3 }
        }
    }
    return Demo().padding()
}
