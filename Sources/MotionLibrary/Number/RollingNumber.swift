import SwiftUI

/// A number whose digits roll up or down when the value changes, like an
/// odometer. Built on `contentTransition(.numericText)`.
///
/// ```swift
/// RollingNumber(value: score)
///     .font(.system(size: 48, weight: .bold, design: .rounded))
/// ```
public struct RollingNumber: View {
    private let value: Double
    private let format: FloatingPointFormatStyle<Double>
    private let animation: Animation

    public init(
        value: Double,
        format: FloatingPointFormatStyle<Double> = .number.precision(.fractionLength(0)),
        animation: Animation = .snappy
    ) {
        self.value = value
        self.format = format
        self.animation = animation
    }

    public init(value: Int, animation: Animation = .snappy) {
        self.init(value: Double(value), animation: animation)
    }

    public var body: some View {
        Text(value, format: format)
            .monospacedDigit()
            .contentTransition(.numericText(value: value))
            .animation(animation, value: value)
    }
}

#Preview {
    struct Demo: View {
        @State private var value = 1280
        var body: some View {
            VStack(spacing: 20) {
                RollingNumber(value: value)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                HStack {
                    Button("-") { value -= Int.random(in: 1...300) }
                    Button("+") { value += Int.random(in: 1...300) }
                }
                .buttonStyle(.bordered)
            }
        }
    }
    return Demo()
}
