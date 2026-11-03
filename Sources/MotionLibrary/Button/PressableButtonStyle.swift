import SwiftUI

/// A button style that squashes slightly and darkens while pressed, then
/// springs back. Adds a light haptic on press (iOS).
///
/// ```swift
/// Button("Continue") { }
///     .buttonStyle(.pressable)
///
/// Button("Big squish") { }
///     .buttonStyle(.pressable(scale: 0.85))
/// ```
public struct PressableButtonStyle: ButtonStyle {
    public var scale: CGFloat
    public var haptics: Bool

    public init(scale: CGFloat = 0.94, haptics: Bool = true) {
        self.scale = scale
        self.haptics = haptics
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .brightness(configuration.isPressed ? -0.06 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .haptic(.lightImpact, trigger: configuration.isPressed) { _, isPressed in
                haptics && isPressed
            }
    }
}

public extension ButtonStyle where Self == PressableButtonStyle {
    static var pressable: PressableButtonStyle { PressableButtonStyle() }

    static func pressable(scale: CGFloat = 0.94, haptics: Bool = true) -> PressableButtonStyle {
        PressableButtonStyle(scale: scale, haptics: haptics)
    }
}

#Preview {
    Button {
    } label: {
        Text("Press me")
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 14)
            .background(Capsule().fill(Color.accentColor))
    }
    .buttonStyle(.pressable)
    .padding()
}
