import SwiftUI

/// A number shown on slot-machine reels. When the value changes, every reel
/// spins a few full turns, blurred with speed, and the reels land one after
/// another from left to right with a small bounce.
public struct SlotMachineNumber: View {
    private let value: Int
    private let digits: Int
    private let size: CGFloat

    /// - Parameters:
    ///   - value: The number to show. Negative values show as 0.
    ///   - digits: Minimum number of reels; the number is zero-padded.
    ///   - size: Font size of the digits.
    public init(value: Int, digits: Int = 3, size: CGFloat = 40) {
        self.value = max(0, value)
        self.digits = max(1, digits)
        self.size = size
    }

    public var body: some View {
        let text = String(value)
        let padded = String(repeating: "0", count: max(0, digits - text.count)) + text
        let numbers = padded.compactMap(\.wholeNumberValue)
        HStack(spacing: size * 0.12) {
            ForEach(numbers.indices, id: \.self) { index in
                SlotReel(digit: numbers[index], size: size, order: index)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(String(value))
    }
}

private struct SlotReel: View {
    let digit: Int
    let size: CGFloat
    let order: Int

    /// Index into the strip of 40 digits (four turns of 0–9).
    @State private var index: Int = 0
    @State private var isSpinning = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let height = size * 1.25
        VStack(spacing: 0) {
            ForEach(0..<40, id: \.self) { row in
                Text("\(row % 10)")
                    .font(.system(size: size, weight: .heavy, design: .rounded))
                    .monospacedDigit()
                    .frame(height: height)
            }
        }
        .offset(y: -CGFloat(index) * height)
        .blur(radius: isSpinning ? size * 0.06 : 0)
        .frame(height: height, alignment: .top)
        .padding(.horizontal, size * 0.12)
        .clipped()
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: size * 0.18))
        .overlay {
            // Shading so the strip looks like it wraps around a drum.
            LinearGradient(stops: [
                .init(color: .black.opacity(0.25), location: 0),
                .init(color: .clear, location: 0.3),
                .init(color: .clear, location: 0.7),
                .init(color: .black.opacity(0.25), location: 1),
            ], startPoint: .top, endPoint: .bottom)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.18))
            .allowsHitTesting(false)
        }
        .onAppear { index = digit }
        .onChange(of: digit) { old, new in spin(from: old, to: new) }
    }

    private func spin(from old: Int, to new: Int) {
        guard !reduceMotion else {
            withAnimation(.easeInOut(duration: 0.3)) { index = new }
            return
        }
        // Start from the old digit on the first turn, land on the fourth.
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) { index = old }
        let duration = 0.9 + Double(order) * 0.25
        isSpinning = true
        withAnimation(.timingCurve(0.3, 0, 0.2, 1.08, duration: duration)) {
            index = 30 + new
        } completion: {
            isSpinning = false
            var settle = Transaction()
            settle.disablesAnimations = true
            withTransaction(settle) { index = new }
        }
        Task { @MainActor in
            // Sharpen up a little before the reel stops.
            try? await Task.sleep(for: .seconds(duration * 0.7))
            withAnimation(.easeOut(duration: duration * 0.3)) { isSpinning = false }
        }
    }
}

#Preview {
    struct Demo: View {
        @State private var value = 777
        var body: some View {
            SlotMachineNumber(value: value)
                .onTapGesture { value = Int.random(in: 0...999) }
                .padding()
        }
    }
    return Demo()
}
