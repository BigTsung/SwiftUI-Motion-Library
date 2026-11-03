import SwiftUI

/// Text laid out around a circle that slowly turns, like a rotating badge or
/// stamp. Put an icon in the middle with a `ZStack`.
public struct CircularText: View {
    private let characters: [String]
    private let text: String
    private let radius: CGFloat
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - text: The text to wrap around the circle. Add a separator such as
    ///     " • " at the end so the start and end don't touch.
    ///   - radius: Radius of the circle the letters stand on, in points.
    ///   - speed: Rotation speed in degrees per second (negative turns
    ///     counter-clockwise, 0 stops it).
    public init(_ text: String, radius: CGFloat = 60, speed: Double = 20) {
        self.text = text
        self.characters = text.map(String.init)
        self.radius = radius
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion || speed == 0)) { timeline in
            let angle = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate * speed
            ZStack {
                ForEach(characters.indices, id: \.self) { index in
                    Text(characters[index])
                        .offset(y: -radius)
                        .rotationEffect(.degrees(Double(index) / Double(max(1, characters.count)) * 360))
                }
            }
            .rotationEffect(.degrees(angle.truncatingRemainder(dividingBy: 360)))
        }
        .frame(width: radius * 2, height: radius * 2)
        .padding(12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }
}

#Preview {
    ZStack {
        CircularText("SWIFTUI • MOTION • LIBRARY • ")
            .font(.system(size: 13, weight: .bold, design: .monospaced))
        Image(systemName: "sparkles")
            .font(.largeTitle)
    }
    .padding()
}
