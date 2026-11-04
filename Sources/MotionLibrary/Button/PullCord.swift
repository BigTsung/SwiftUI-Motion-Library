import SwiftUI

/// A toggle you pull like a lamp cord: drag the knob down, it stretches with
/// rubber-band resistance, and past the catch point it clicks, flips the
/// value and springs back up, swinging. A tap also toggles it.
///
/// ```swift
/// PullCord(isOn: $lightsOn)
/// ```
public struct PullCord: View {
    @Binding private var isOn: Bool
    private let length: CGFloat
    private let color: Color

    @State private var stretch: CGFloat = 0
    @State private var swing: Double = 0
    @State private var clicks = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - isOn: The value the cord toggles.
    ///   - length: Length of the cord at rest, in points.
    ///   - color: Colour of the cord and knob.
    public init(isOn: Binding<Bool>, length: CGFloat = 70, color: Color = .primary) {
        _isOn = isOn
        self.length = length
        self.color = color
    }

    private var catchPoint: CGFloat { length * 0.45 }

    public var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(color.opacity(0.7))
                .frame(width: 2, height: length + stretch)
            Capsule()
                .fill(isOn ? Color.yellow : color)
                .overlay(Capsule().strokeBorder(color.opacity(0.4), lineWidth: 1))
                .frame(width: 16, height: 26)
                .shadow(color: isOn ? .yellow.opacity(0.7) : .clear, radius: 8)
        }
        .rotationEffect(.degrees(swing), anchor: .top)
        .frame(width: 60, height: length + 26 + catchPoint * 1.6, alignment: .top)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    // Rubber band: easy at first, then stiffer.
                    let pull = max(0, value.translation.height)
                    stretch = catchPoint * 1.6 * (1 - exp(-pull / (catchPoint * 1.6)))
                    swing = reduceMotion ? 0 : Double(-value.translation.width / 6).clamped(to: -18...18)
                }
                .onEnded { value in
                    let pulled = stretch > catchPoint || (abs(value.translation.height) < 4 && abs(value.translation.width) < 4)
                    if pulled { toggle() }
                    withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.55, bounce: 0.6)) {
                        stretch = 0
                    }
                    if reduceMotion {
                        swing = 0
                    } else {
                        // Swing out a little the other way, then settle.
                        withAnimation(.spring(duration: 0.9, bounce: 0.7)) { swing = 0 }
                    }
                }
        )
        .haptic(.lightImpact, trigger: clicks)
        .accessibilityElement()
        .accessibilityLabel("Pull cord")
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { toggle() }
    }

    private func toggle() {
        isOn.toggle()
        clicks += 1
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double { Swift.min(range.upperBound, Swift.max(range.lowerBound, self)) }
}

#Preview {
    struct Demo: View {
        @State private var on = false
        var body: some View {
            ZStack(alignment: .top) {
                (on ? Color.yellow.opacity(0.15) : Color.black.opacity(0.05))
                PullCord(isOn: $on)
            }
            .frame(width: 200, height: 220)
        }
    }
    return Demo()
}
