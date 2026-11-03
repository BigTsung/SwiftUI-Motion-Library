import SwiftUI

/// An SF Symbol that keeps playing a symbol effect: a bounce on a beat, or a
/// continuous pulse, variable-colour cycle or scale-up.
public struct AnimatedSymbol: View {
    /// Which symbol effect to play.
    public enum Style: CaseIterable, Sendable {
        /// Bounces once every `interval` seconds.
        case bounce
        /// Fades the symbol's layers in and out.
        case pulse
        /// Lights up the symbol's layers one after another (wifi, speaker…).
        case variableColor
        /// Grows the symbol slightly and holds it.
        case scaleUp
    }

    private let systemName: String
    private let style: Style
    private let isActive: Bool
    private let interval: Double

    @State private var beats = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - systemName: The SF Symbol name.
    ///   - style: The effect to play.
    ///   - isActive: Pauses the effect when false.
    ///   - interval: Seconds between bounces (`.bounce` only).
    public init(_ systemName: String, style: Style = .bounce, isActive: Bool = true, interval: Double = 1.5) {
        self.systemName = systemName
        self.style = style
        self.isActive = isActive
        self.interval = interval
    }

    public var body: some View {
        // Reduce Motion: the symbol stays still.
        let active = isActive && !reduceMotion
        let image = Image(systemName: systemName)
        Group {
            switch style {
            case .bounce:
                image.symbolEffect(.bounce, value: beats)
            case .pulse:
                image.symbolEffect(.pulse, isActive: active)
            case .variableColor:
                image.symbolEffect(.variableColor.iterative.reversing, isActive: active)
            case .scaleUp:
                image.symbolEffect(.scale.up, isActive: active)
            }
        }
        .task(id: active) {
            guard style == .bounce, active else { return }
            while !Task.isCancelled {
                beats += 1
                try? await Task.sleep(for: .seconds(max(0.3, interval)))
            }
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        AnimatedSymbol("bell.fill")
        AnimatedSymbol("heart.fill", style: .pulse)
        AnimatedSymbol("wifi", style: .variableColor)
        AnimatedSymbol("mic.fill", style: .scaleUp)
    }
    .font(.largeTitle)
    .padding()
}
