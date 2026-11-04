import SwiftUI

/// A number that counts up from zero on appear, and counts from the old value
/// to the new one whenever `value` changes.
public struct CountUpText: View {
    private let value: Double
    private let duration: Double
    private let fractionDigits: Int
    private let prefix: String
    private let suffix: String

    @State private var shown: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - value: The number to count to.
    ///   - duration: Length of the count, in seconds.
    ///   - fractionDigits: Digits after the decimal point.
    ///   - prefix: Text before the number, e.g. "$".
    ///   - suffix: Text after the number, e.g. "%".
    public init(
        value: Double,
        duration: Double = 1.4,
        fractionDigits: Int = 0,
        prefix: String = "",
        suffix: String = ""
    ) {
        self.value = value
        self.duration = duration
        self.fractionDigits = fractionDigits
        self.prefix = prefix
        self.suffix = suffix
    }

    public var body: some View {
        CountingLabel(value: shown, fractionDigits: fractionDigits, prefix: prefix, suffix: suffix)
            .monospacedDigit()
            .onAppear { count(to: value) }
            .onChange(of: value) { _, newValue in count(to: newValue) }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(CountingLabel.format(value, fractionDigits: fractionDigits, prefix: prefix, suffix: suffix))
    }

    private func count(to target: Double) {
        // Reduce Motion: jump straight to the value.
        withAnimation(reduceMotion ? nil : .easeOut(duration: duration)) {
            shown = target
        }
    }
}

/// Re-renders the formatted number for every animation frame.
private struct CountingLabel: View, Animatable {
    var value: Double
    let fractionDigits: Int
    let prefix: String
    let suffix: String

    nonisolated var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text(Self.format(value, fractionDigits: fractionDigits, prefix: prefix, suffix: suffix))
    }

    static func format(_ value: Double, fractionDigits: Int, prefix: String, suffix: String) -> String {
        prefix + value.formatted(.number.precision(.fractionLength(max(0, fractionDigits)))) + suffix
    }
}

#Preview {
    VStack(spacing: 12) {
        CountUpText(value: 12_480)
            .font(.largeTitle.bold())
        CountUpText(value: 98.6, fractionDigits: 1, suffix: "%")
            .font(.title)
    }
    .padding()
}
