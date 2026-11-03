import SwiftUI

/// A speedometer-style gauge: a 240° arc that fills with a gradient, tick
/// marks, and a needle that swings to the value on a spring, overshooting a
/// little before it settles.
public struct NeedleGauge: View {
    private let value: Double
    private let colors: [Color]
    private let label: String?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let sweep = 240.0

    /// - Parameters:
    ///   - value: 0 (needle far left) to 1 (far right). Clamped.
    ///   - colors: Gradient along the arc, from 0 to 1.
    ///   - label: Optional caption under the needle; defaults to a percentage.
    public init(value: Double, colors: [Color] = [.green, .yellow, .red], label: String? = nil) {
        self.value = min(1, max(0, value))
        self.colors = colors
        self.label = label
    }

    public var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let lineWidth = side * 0.08
            ZStack {
                arc(to: 1)
                    .stroke(Color.secondary.opacity(0.15), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                arc(to: value)
                    .stroke(
                        AngularGradient(colors: colors, center: .center, startAngle: .degrees(90 + (360 - sweep) / 2), endAngle: .degrees(90 + (360 - sweep) / 2 + sweep)),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                ForEach(0...10, id: \.self) { tick in
                    Capsule()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: tick.isMultiple(of: 5) ? 2.5 : 1.5, height: side * (tick.isMultiple(of: 5) ? 0.08 : 0.05))
                        .offset(y: -side * 0.32)
                        .rotationEffect(.degrees(-sweep / 2 + sweep * Double(tick) / 10))
                }
                Capsule()
                    .fill(Color.primary)
                    .frame(width: side * 0.025, height: side * 0.36)
                    .offset(y: -side * 0.14)
                    .rotationEffect(.degrees(-sweep / 2 + sweep * value))
                    .animation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(duration: 0.9, bounce: 0.45), value: value)
                Circle()
                    .fill(Color.primary)
                    .frame(width: side * 0.08, height: side * 0.08)
                Text(label ?? "\(Int((value * 100).rounded()))%")
                    .font(.system(size: side * 0.11, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText(value: value))
                    .animation(.snappy, value: value)
                    .offset(y: side * 0.24)
            }
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("Gauge")
        .accessibilityValue(label ?? "\(Int((value * 100).rounded())) percent")
    }

    /// The arc from the left end to `fraction` of the sweep.
    private func arc(to fraction: Double) -> some Shape {
        GaugeArc(sweep: sweep, fraction: fraction)
    }
}

struct GaugeArc: Shape {
    var sweep: Double
    var fraction: Double

    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) * 0.42
        let start = 90 + (360 - sweep) / 2
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: radius, startAngle: .degrees(start), endAngle: .degrees(start + sweep * fraction), clockwise: false)
        return path
    }
}

#Preview {
    struct Demo: View {
        @State private var value = 0.3
        var body: some View {
            NeedleGauge(value: value)
                .frame(width: 200, height: 200)
                .onTapGesture { value = Double.random(in: 0...1) }
        }
    }
    return Demo()
}
