import SwiftUI

/// Letters blast apart in random directions, spinning, and spring back into
/// place, drawn with a `TextRenderer` so the text keeps its normal layout.
@available(iOS 18, macOS 15, visionOS 2, *)
public struct ExplodingText: View {
    private let string: String
    private let isExploded: Bool
    private let distance: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - string: The text to show.
    ///   - isExploded: `true` scatters the letters, `false` reassembles them.
    ///   - distance: How far letters fly, in points.
    public init(_ string: String, isExploded: Bool, distance: CGFloat = 60) {
        self.string = string
        self.isExploded = isExploded
        self.distance = distance
    }

    public var body: some View {
        Text(string)
            .textRenderer(ExplodeRenderer(
                progress: isExploded ? 1 : 0,
                distance: reduceMotion ? 0 : distance
            ))
            // Out fast, back on a bouncy spring. Reduce Motion: a fade only.
            .animation(
                reduceMotion ? .easeInOut(duration: 0.3)
                    : isExploded ? .easeOut(duration: 0.45) : .spring(duration: 0.8, bounce: 0.35),
                value: isExploded
            )
            .accessibilityLabel(string)
    }
}

@available(iOS 18, macOS 15, visionOS 2, *)
struct ExplodeRenderer: TextRenderer, Animatable {
    /// 0 = assembled, 1 = fully scattered.
    var progress: Double
    var distance: CGFloat

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var displayPadding: EdgeInsets {
        EdgeInsets(top: distance, leading: distance, bottom: distance, trailing: distance)
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        var index = 0
        for line in layout {
            for run in line {
                for glyph in run {
                    let random = Self.random(index)
                    let angle = random.0 * 2 * .pi
                    let reach = distance * (0.5 + 0.5 * random.1)
                    let bounds = glyph.typographicBounds.rect
                    var copy = context
                    copy.opacity = 1 - 0.7 * min(1, max(0, progress))
                    copy.translateBy(x: cos(angle) * reach * progress, y: sin(angle) * reach * progress)
                    // Spin around the glyph's own centre.
                    copy.translateBy(x: bounds.midX, y: bounds.midY)
                    copy.rotate(by: .degrees((random.2 - 0.5) * 540 * progress))
                    copy.translateBy(x: -bounds.midX, y: -bounds.midY)
                    copy.draw(glyph)
                    index += 1
                }
            }
        }
    }

    /// Three stable pseudo-random values in 0..<1 for a glyph index.
    static func random(_ index: Int) -> (Double, Double, Double) {
        func hash(_ n: Int) -> Double {
            var x = UInt64(truncatingIfNeeded: n &* 2_654_435_761)
            x = (x ^ (x >> 31)) &* 0x9E37_79B9_7F4A_7C15
            x ^= x >> 29
            return Double(x % 10_000) / 10_000
        }
        return (hash(index * 3 + 1), hash(index * 3 + 2), hash(index * 3 + 3))
    }
}

@available(iOS 18, macOS 15, visionOS 2, *)
private struct ExplodingTextPreview: View {
    @State private var exploded = false

    var body: some View {
        ExplodingText("Kaboom!", isExploded: exploded)
            .font(.system(size: 44, weight: .heavy, design: .rounded))
            .onTapGesture { exploded.toggle() }
            .padding(60)
    }
}

#Preview {
    if #available(iOS 18, macOS 15, visionOS 2, *) {
        ExplodingTextPreview()
    }
}
