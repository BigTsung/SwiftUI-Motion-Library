import SwiftUI

/// "Decoding" text effect: random glyphs settle into the real string from
/// left to right.
///
/// ```swift
/// ScrambleText("ACCESS GRANTED")
///     .font(.title.bold())
/// ```
public struct ScrambleText: View {
    private let text: String
    private let duration: Double
    private let charset: [Character]

    @State private var display: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        _ text: String,
        duration: Double = 1.0,
        charset: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#%&*"
    ) {
        self.text = text
        self.duration = duration
        self.charset = Array(charset)
        _display = State(initialValue: text)
    }

    public var body: some View {
        Text(display)
            .fontDesign(.monospaced)
            .accessibilityLabel(text)
            .task(id: text) {
                await run()
            }
    }

    private func run() async {
        // Reduce Motion: show the text without the flicker of random glyphs.
        guard !reduceMotion else {
            display = text
            return
        }
        let target = Array(text)
        let frameInterval = 0.03
        let steps = max(1, Int(duration / frameInterval))

        for step in 0...steps {
            let revealed = Int(Double(target.count) * Double(step) / Double(steps))
            var output: [Character] = []
            output.reserveCapacity(target.count)
            for (index, character) in target.enumerated() {
                if index < revealed || character == " " || charset.isEmpty {
                    output.append(character)
                } else {
                    output.append(charset.randomElement() ?? character)
                }
            }
            display = String(output)

            try? await Task.sleep(for: .seconds(frameInterval))
            if Task.isCancelled { return }
        }
        display = text
    }
}

#Preview {
    ScrambleText("ACCESS GRANTED", duration: 1.2)
        .font(.title.bold())
        .padding()
}
