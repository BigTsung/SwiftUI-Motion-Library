import SwiftUI

/// Letters swell from thin to black and back in a travelling wave, like a
/// variable font being played. Uses the font from the environment.
public struct WeightWaveText: View {
    private let string: String
    private let speed: Double
    private let wavelength: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let weights: [Font.Weight] = [
        .ultraLight, .thin, .light, .regular, .medium, .semibold, .bold, .heavy, .black,
    ]

    /// - Parameters:
    ///   - string: The text to show.
    ///   - speed: Multiplier on the default pace: 1 is normal, 2 twice as fast, 0.5 half as fast.
    ///   - wavelength: Letters per wave.
    public init(_ string: String, speed: Double = 1, wavelength: Double = 8) {
        self.string = string
        self.speed = speed * 0.6
        self.wavelength = max(1, wavelength)
    }

    public var body: some View {
        let characters = Array(string)
        TimelineView(.animation(paused: reduceMotion || speed == 0)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: 0) {
                ForEach(characters.indices, id: \.self) { index in
                    Text(String(characters[index]))
                        .fontWeight(reduceMotion ? .regular : weight(index: index, time: time))
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel(string)
    }

    private func weight(index: Int, time: Double) -> Font.Weight {
        let phase = (Double(index) / wavelength - time * speed) * 2 * .pi
        let level = (sin(phase) + 1) / 2
        let weights = Self.weights
        return weights[min(weights.count - 1, Int(level * Double(weights.count)))]
    }
}

#Preview {
    WeightWaveText("Variable weight")
        .font(.system(size: 36, design: .rounded))
        .padding()
}
