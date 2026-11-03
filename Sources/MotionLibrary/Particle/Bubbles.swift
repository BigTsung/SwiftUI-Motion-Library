import SwiftUI

/// Soap bubbles rise from the bottom, wobbling side to side, with a
/// rainbow-tinted rim and a glossy highlight, and fade out near the top.
public struct Bubbles: View {
    private let count: Int
    private let color: Color
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - count: Number of bubbles in flight.
    ///   - color: Rim tint.
    ///   - speed: Multiplier on the rising speed.
    public init(count: Int = 18, color: Color = .cyan, speed: Double = 1) {
        self.count = max(1, count)
        self.color = color
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let time = reduceMotion ? 5 : timeline.date.timeIntervalSinceReferenceDate * speed
            Canvas { context, size in
                for index in 0..<count {
                    let seed = Double(index)
                    let r = CGFloat(6 + Self.hash(index, 1) * 16)
                    let duration = 4 + Self.hash(index, 2) * 4
                    let progress = ((time + Self.hash(index, 3) * duration) / duration).truncatingRemainder(dividingBy: 1)
                    let baseX = Self.hash(index, 4) * size.width
                    let x = baseX + sin(time * (1 + Self.hash(index, 5)) + seed) * 14
                    let y = size.height + r - (size.height + r * 2) * progress
                    let fade = progress > 0.8 ? (1 - progress) / 0.2 : min(1, progress * 6)
                    let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                    var bubble = context
                    bubble.opacity = fade
                    bubble.fill(Path(ellipseIn: rect), with: .radialGradient(
                        Gradient(colors: [color.opacity(0.02), color.opacity(0.12), color.opacity(0.35)]),
                        center: CGPoint(x: x, y: y), startRadius: 0, endRadius: r
                    ))
                    bubble.stroke(Path(ellipseIn: rect), with: .linearGradient(
                        Gradient(colors: [.pink.opacity(0.7), color.opacity(0.8), .purple.opacity(0.6)]),
                        startPoint: CGPoint(x: rect.minX, y: rect.minY), endPoint: CGPoint(x: rect.maxX, y: rect.maxY)
                    ), lineWidth: 1)
                    let shine = CGRect(x: x - r * 0.55, y: y - r * 0.6, width: r * 0.45, height: r * 0.3)
                    bubble.fill(Path(ellipseIn: shine), with: .color(.white.opacity(0.75)))
                }
            }
        }
        .accessibilityHidden(true)
    }

    static func hash(_ a: Int, _ b: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: a &* 1_103_515_245 &+ b &* 12_345 &+ 777)
        x = (x ^ (x >> 16)) &* 0x45d9_f3b
        x ^= x >> 16
        return Double(x % 10_000) / 10_000
    }
}

#Preview {
    Bubbles()
        .frame(width: 300, height: 220)
        .background(LinearGradient(colors: [.blue.opacity(0.5), .indigo], startPoint: .top, endPoint: .bottom))
}
