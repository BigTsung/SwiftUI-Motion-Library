import SwiftUI

/// A live price: digits roll to the new value, the background flashes green
/// or red, and an arrow shows which way it moved.
public struct PriceTicker: View {
    private let value: Double
    private let fractionDigits: Int
    private let prefix: String

    @State private var direction: Direction = .flat
    @State private var flashes = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Direction { case up, down, flat }

    /// - Parameters:
    ///   - value: The current price.
    ///   - fractionDigits: Decimal places to show.
    ///   - prefix: Text before the number, such as a currency symbol.
    public init(value: Double, fractionDigits: Int = 2, prefix: String = "$") {
        self.value = value
        self.fractionDigits = fractionDigits
        self.prefix = prefix
    }

    public var body: some View {
        let color: Color = direction == .up ? .green : direction == .down ? .red : .secondary
        HStack(spacing: 6) {
            Image(systemName: direction == .down ? "arrowtriangle.down.fill" : "arrowtriangle.up.fill")
                .font(.system(size: 10))
                .foregroundStyle(color)
                .opacity(direction == .flat ? 0 : 1)
                .contentTransition(.symbolEffect(.replace))
            Text(prefix + value.formatted(.number.precision(.fractionLength(fractionDigits))))
                .monospacedDigit()
                .contentTransition(.numericText(value: value))
                .foregroundStyle(direction == .flat ? Color.primary : color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .keyframeAnimator(initialValue: 0.0, trigger: flashes) { view, opacity in
                    view.opacity(opacity)
                } keyframes: { _ in
                    LinearKeyframe(0.3, duration: 0.05)
                    LinearKeyframe(0, duration: 0.9)
                }
        }
        .animation(reduceMotion ? nil : .snappy(duration: 0.35), value: value)
        .onChange(of: value) { old, new in
            direction = new > old ? .up : new < old ? .down : .flat
            if !reduceMotion { flashes += 1 }
        }
    }
}

#Preview {
    struct Demo: View {
        @State private var price = 182.40
        var body: some View {
            PriceTicker(value: price)
                .font(.title2.bold())
                .task {
                    while !Task.isCancelled {
                        try? await Task.sleep(for: .seconds(1.2))
                        price += Double.random(in: -2...2)
                    }
                }
                .padding()
        }
    }
    return Demo()
}
