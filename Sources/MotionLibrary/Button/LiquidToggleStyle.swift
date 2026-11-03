import SwiftUI

/// A switch whose knob stretches like a drop of liquid as it slides across,
/// then springs back to a circle.
///
/// ```swift
/// Toggle("Wi-Fi", isOn: $isOn)
///     .toggleStyle(.liquid)
///
/// Toggle("Dark mode", isOn: $dark)
///     .toggleStyle(.liquid(tint: .purple))
/// ```
public struct LiquidToggleStyle: ToggleStyle {
    public var tint: Color

    public init(tint: Color = .green) {
        self.tint = tint
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer(minLength: 12)
            LiquidSwitch(isOn: configuration.$isOn, tint: tint)
        }
    }
}

private struct LiquidSwitch: View {
    @Binding var isOn: Bool
    let tint: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let width: CGFloat = 52
    private let height: CGFloat = 32
    private let knob: CGFloat = 26

    var body: some View {
        let knob = knob
        // Reduce Motion: no stretch.
        let stretch = reduceMotion ? knob : knob * 1.5
        return Button {
            withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.35, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? tint : Color.gray.opacity(0.35))
                Capsule()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
                    .keyframeAnimator(initialValue: knob, trigger: isOn) { view, knobWidth in
                        view.frame(width: knobWidth, height: knob)
                    } keyframes: { _ in
                        CubicKeyframe(stretch, duration: 0.12)
                        SpringKeyframe(knob, duration: 0.35, spring: .bouncy)
                    }
                    .padding(3)
            }
            .frame(width: width, height: height)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

public extension ToggleStyle where Self == LiquidToggleStyle {
    /// A switch with a stretchy, liquid knob.
    static var liquid: LiquidToggleStyle { LiquidToggleStyle() }

    /// A switch with a stretchy, liquid knob in the given colour.
    static func liquid(tint: Color) -> LiquidToggleStyle { LiquidToggleStyle(tint: tint) }
}

#Preview {
    struct Demo: View {
        @State private var on = true
        var body: some View {
            Toggle("Notifications", isOn: $on)
                .toggleStyle(.liquid)
                .frame(width: 240)
        }
    }
    return Demo().padding()
}
