import SwiftUI

/// Text that fills with liquid: a wavy water line rises inside the glyphs as
/// `progress` goes from 0 to 1, with a second, lighter wave behind it.
///
/// ```swift
/// LiquidFillText("72%", progress: 0.72, color: .cyan)
///     .font(.system(size: 64, weight: .black, design: .rounded))
/// ```
public struct LiquidFillText: View {
    private let text: String
    private let progress: Double
    private let color: Color
    private let waveHeight: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - text: The string to fill.
    ///   - progress: Fill level, 0 (empty) to 1 (full). Changes animate.
    ///   - color: Colour of the liquid.
    ///   - waveHeight: Height of the waves, in points.
    public init(_ text: String, progress: Double, color: Color = .blue, waveHeight: CGFloat = 6) {
        self.text = text
        self.progress = min(1, max(0, progress))
        self.color = color
        self.waveHeight = waveHeight
    }

    public var body: some View {
        Text(text)
            .foregroundStyle(color.opacity(0.15))
            .overlay {
                TimelineView(.animation(paused: reduceMotion)) { timeline in
                    let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                    ZStack {
                        LiquidWave(level: progress, phase: time * 2.2 + 1.3, amplitude: waveHeight * 0.8)
                            .fill(color.opacity(0.45))
                        LiquidWave(level: progress, phase: time * 3, amplitude: waveHeight)
                            .fill(color)
                    }
                    .animation(.spring(duration: 0.9, bounce: 0.25), value: progress)
                }
                .mask { Text(text) }
                .accessibilityHidden(true)
            }
            .accessibilityLabel(text)
    }
}

/// A sine-wave water line at `level` (0 = bottom, 1 = top), filled below.
struct LiquidWave: Shape {
    var level: Double
    var phase: Double
    var amplitude: CGFloat

    nonisolated var animatableData: Double {
        get { level }
        set { level = newValue }
    }

    nonisolated func path(in rect: CGRect) -> Path {
        // A line of text has room for descenders below the glyphs and accents
        // above them; fill between roughly the baseline and the cap height,
        // going a wave's height past both so 0 is empty and 1 full.
        let bottom = rect.maxY - rect.height * 0.2 + amplitude * 2
        let top = rect.minY + rect.height * 0.12 - amplitude * 2
        let baseline = bottom - (bottom - top) * level
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        let steps = max(8, Int(rect.width / 4))
        for step in 0...steps {
            let x = rect.minX + rect.width * CGFloat(step) / CGFloat(steps)
            let angle = Double(x / max(rect.width, 1)) * 2 * .pi * 1.5 + phase
            path.addLine(to: CGPoint(x: x, y: baseline + amplitude * sin(angle)))
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    struct Demo: View {
        @State private var progress = 0.3
        var body: some View {
            LiquidFillText("72%", progress: progress, color: .cyan)
                .font(.system(size: 80, weight: .black, design: .rounded))
                .onTapGesture { progress = progress > 0.8 ? 0.1 : progress + 0.3 }
        }
    }
    return Demo()
}
