import SwiftUI

/// Letters bob up and down in a travelling wave, drawn with a `TextRenderer`
/// so the text keeps its normal layout, wrapping and accessibility.
@available(iOS 18, macOS 15, visionOS 2, *)
public struct WaveText: View {
    private let text: Text
    private let amplitude: CGFloat
    private let wavelength: Double
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - text: The string to show.
    ///   - amplitude: How far letters move up and down, in points.
    ///   - wavelength: Number of letters in one full wave.
    ///   - speed: Waves per second.
    public init(_ text: String, amplitude: CGFloat = 5, wavelength: Double = 8, speed: Double = 1) {
        self.init(Text(text), amplitude: amplitude, wavelength: wavelength, speed: speed)
    }

    /// Wraps an existing `Text`, keeping its styling.
    public init(_ text: Text, amplitude: CGFloat = 5, wavelength: Double = 8, speed: Double = 1) {
        self.text = text
        self.amplitude = amplitude
        self.wavelength = wavelength
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            text.textRenderer(WaveRenderer(
                time: reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate,
                amplitude: reduceMotion ? 0 : amplitude,
                wavelength: wavelength,
                speed: speed
            ))
        }
    }
}

@available(iOS 18, macOS 15, visionOS 2, *)
struct WaveRenderer: TextRenderer {
    var time: Double
    var amplitude: CGFloat
    var wavelength: Double
    var speed: Double

    var displayPadding: EdgeInsets {
        EdgeInsets(top: amplitude, leading: 0, bottom: amplitude, trailing: 0)
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        var index = 0
        for line in layout {
            for run in line {
                for glyph in run {
                    let angle = (Double(index) / max(wavelength, 1) - time * speed) * 2 * .pi
                    var copy = context
                    copy.translateBy(x: 0, y: CGFloat(sin(angle)) * amplitude)
                    copy.draw(glyph)
                    index += 1
                }
            }
        }
    }
}

#Preview {
    if #available(iOS 18, macOS 15, visionOS 2, *) {
        WaveText("Making waves in SwiftUI")
            .font(.title.bold())
            .foregroundStyle(.blue)
            .padding()
    }
}
