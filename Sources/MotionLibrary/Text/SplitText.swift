import SwiftUI

/// Letters rise into place one after another with a small overshoot, drawn
/// with a `TextRenderer` so the text keeps its normal layout and wrapping.
/// Plays on appear and again when the string changes.
@available(iOS 18, macOS 15, visionOS 2, *)
public struct SplitText: View {
    private let string: String
    private let duration: Double
    private let stagger: Double
    private let distance: CGFloat

    @State private var progress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - string: The text to show.
    ///   - duration: How long each letter takes to land, in seconds.
    ///   - stagger: Delay between consecutive letters, in seconds.
    ///   - distance: How far below its place each letter starts, in points.
    public init(_ string: String, duration: Double = 0.5, stagger: Double = 0.035, distance: CGFloat = 18) {
        self.string = string
        self.duration = duration
        self.stagger = stagger
        self.distance = distance
    }

    public var body: some View {
        let glyphs = max(1, string.count)
        let total = duration + stagger * Double(glyphs - 1)
        Text(string)
            .textRenderer(SplitRenderer(
                progress: progress,
                spread: total > 0 ? stagger * Double(glyphs - 1) / total : 0,
                distance: reduceMotion ? 0 : distance
            ))
            .task(id: string) {
                var reset = Transaction()
                reset.disablesAnimations = true
                withTransaction(reset) { progress = 0 }
                try? await Task.sleep(for: .milliseconds(16))
                withAnimation(.linear(duration: reduceMotion ? 0.3 : total)) { progress = 1 }
            }
    }
}

@available(iOS 18, macOS 15, visionOS 2, *)
struct SplitRenderer: TextRenderer, Animatable {
    /// 0 = nothing shown, 1 = every letter in place.
    var progress: Double
    /// Fraction of the timeline taken up by the delays between letters.
    var spread: Double
    var distance: CGFloat

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var displayPadding: EdgeInsets {
        EdgeInsets(top: 0, leading: 0, bottom: distance, trailing: 0)
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let count = layout.flatMap { $0 }.reduce(0) { $0 + $1.count }
        var index = 0
        for line in layout {
            for run in line {
                for glyph in run {
                    let start = count > 1 ? spread * Double(index) / Double(count - 1) : 0
                    let local = min(1, max(0, (progress - start) / max(0.0001, 1 - spread)))
                    var copy = context
                    copy.opacity = min(1, local * 2)
                    copy.translateBy(x: 0, y: (1 - Self.backOut(local)) * distance)
                    copy.draw(glyph)
                    index += 1
                }
            }
        }
    }

    /// Ease-out with a small overshoot.
    static func backOut(_ t: Double) -> Double {
        let c1 = 1.70158, c3 = c1 + 1
        return 1 + c3 * pow(t - 1, 3) + c1 * pow(t - 1, 2)
    }
}

#Preview {
    if #available(iOS 18, macOS 15, visionOS 2, *) {
        SplitText("Letters take the stage")
            .font(.largeTitle.bold())
            .padding()
    }
}
