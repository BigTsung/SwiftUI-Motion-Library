import SwiftUI

/// A bar chart whose bars grow up from the baseline one after another on
/// appear, and spring to their new heights when the values change.
public struct GrowingBarChart: View {
    private let values: [Double]
    private let color: Color
    private let spacing: CGFloat

    @State private var grown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - values: Bar values; the tallest fills the height.
    ///   - color: Bar colour.
    ///   - spacing: Gap between bars, as a fraction of a bar's width.
    public init(values: [Double], color: Color = .accentColor, spacing: CGFloat = 0.35) {
        self.values = values
        self.color = color
        self.spacing = spacing
    }

    public var body: some View {
        let top = max(values.max() ?? 1, 0.0001)
        GeometryReader { geometry in
            let count = CGFloat(max(1, values.count))
            let barWidth = geometry.size.width / (count + (count - 1) * spacing)
            HStack(alignment: .bottom, spacing: barWidth * spacing) {
                ForEach(values.indices, id: \.self) { index in
                    let fraction = grown ? max(0, values[index]) / top : 0
                    UnevenRoundedRectangle(topLeadingRadius: barWidth * 0.25, topTrailingRadius: barWidth * 0.25)
                        .fill(color.gradient)
                        .frame(width: barWidth, height: max(2, geometry.size.height * fraction))
                        .animation(
                            reduceMotion ? .easeOut(duration: 0.3)
                                : .spring(duration: 0.6, bounce: 0.3).delay(grown ? Double(index) * 0.06 : 0),
                            value: grown
                        )
                        .animation(reduceMotion ? nil : .spring(duration: 0.6, bounce: 0.3), value: values[index])
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .onAppear { grown = true }
        .accessibilityElement()
        .accessibilityLabel("Bar chart")
        .accessibilityValue(values.map { $0.formatted() }.joined(separator: ", "))
    }
}

/// A line chart that draws itself from left to right, with a gradient area
/// that fades in underneath and a dot that lands on the last point. Redraws
/// when the values change.
public struct DrawingLineChart: View {
    private let values: [Double]
    private let color: Color
    private let duration: Double

    @State private var progress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - values: The points, left to right.
    ///   - color: Line colour.
    ///   - duration: Seconds to draw the line.
    public init(values: [Double], color: Color = .accentColor, duration: Double = 1.2) {
        self.values = values
        self.color = color
        self.duration = duration
    }

    public var body: some View {
        ZStack {
            ChartLine(values: values, closed: true)
                .fill(LinearGradient(colors: [color.opacity(0.35), color.opacity(0)], startPoint: .top, endPoint: .bottom))
                .opacity(progress)
            ChartLine(values: values, closed: false)
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            GeometryReader { geometry in
                if let last = ChartLine.points(values, in: CGRect(origin: .zero, size: geometry.size)).last {
                    Circle()
                        .fill(color)
                        .frame(width: 9, height: 9)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                        .position(last)
                        .scaleEffect(progress >= 1 ? 1 : 0.01, anchor: UnitPoint(x: last.x / max(1, geometry.size.width), y: last.y / max(1, geometry.size.height)))
                        .animation(.spring(duration: 0.35, bounce: 0.5), value: progress >= 1)
                }
            }
        }
        .task(id: values) {
            var reset = Transaction()
            reset.disablesAnimations = true
            withTransaction(reset) { progress = 0 }
            try? await Task.sleep(for: .milliseconds(16))
            withAnimation(reduceMotion ? .easeOut(duration: 0.3) : .easeInOut(duration: duration)) { progress = 1 }
        }
        .accessibilityElement()
        .accessibilityLabel("Line chart")
        .accessibilityValue(values.map { $0.formatted() }.joined(separator: ", "))
    }
}

struct ChartLine: Shape {
    var values: [Double]
    var closed: Bool

    static func points(_ values: [Double], in rect: CGRect) -> [CGPoint] {
        guard values.count > 1, let low = values.min(), let high = values.max() else { return [] }
        let range = max(high - low, 0.0001)
        // A little headroom so the stroke and dot aren't clipped.
        let inset = rect.insetBy(dx: 5, dy: 6)
        return values.enumerated().map { index, value in
            CGPoint(
                x: inset.minX + inset.width * CGFloat(index) / CGFloat(values.count - 1),
                y: inset.maxY - inset.height * CGFloat((value - low) / range)
            )
        }
    }

    nonisolated func path(in rect: CGRect) -> Path {
        let points = Self.points(values, in: rect)
        var path = Path()
        guard let first = points.first, let last = points.last else { return path }
        path.move(to: first)
        // Smooth the line with midpoint quadratic curves.
        for index in 1..<points.count {
            let previous = points[index - 1], point = points[index]
            let mid = CGPoint(x: (previous.x + point.x) / 2, y: (previous.y + point.y) / 2)
            path.addQuadCurve(to: mid, control: previous)
            if index == points.count - 1 { path.addQuadCurve(to: point, control: point) }
        }
        if closed {
            path.addLine(to: CGPoint(x: last.x, y: rect.maxY))
            path.addLine(to: CGPoint(x: first.x, y: rect.maxY))
            path.closeSubpath()
        }
        return path
    }
}

#Preview {
    VStack(spacing: 30) {
        GrowingBarChart(values: [3, 7, 4, 9, 6, 8]).frame(width: 220, height: 100)
        DrawingLineChart(values: [3, 5, 4, 8, 6, 9, 7, 11]).frame(width: 220, height: 100)
    }
    .padding()
}
