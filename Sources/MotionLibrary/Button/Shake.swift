import SwiftUI

/// Horizontal "no" shake, e.g. for a wrong password. Plays every time
/// `trigger` changes.
struct ShakeModifier<Trigger: Equatable>: ViewModifier {
    var trigger: Trigger
    var amplitude: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        // Reduce Motion: no shake (pair it with a colour or message change).
        let scale: CGFloat = reduceMotion ? 0 : 1
        return content.keyframeAnimator(initialValue: CGFloat(0), trigger: trigger) { view, offset in
            view.offset(x: offset * scale)
        } keyframes: { _ in
            KeyframeTrack {
                CubicKeyframe(-amplitude, duration: 0.07)
                CubicKeyframe(amplitude, duration: 0.07)
                CubicKeyframe(-amplitude * 0.7, duration: 0.07)
                CubicKeyframe(amplitude * 0.7, duration: 0.07)
                CubicKeyframe(-amplitude * 0.3, duration: 0.06)
                SpringKeyframe(0, duration: 0.2, spring: .bouncy)
            }
        }
    }
}

public extension View {
    /// Shakes the view horizontally whenever `trigger` changes.
    ///
    /// ```swift
    /// @State private var attempts = 0
    ///
    /// SecureField("Password", text: $password)
    ///     .shake(trigger: attempts)
    /// // on failure: attempts += 1
    /// ```
    func shake<Trigger: Equatable>(trigger: Trigger, amplitude: CGFloat = 10) -> some View {
        modifier(ShakeModifier(trigger: trigger, amplitude: amplitude))
    }
}

#Preview {
    struct Demo: View {
        @State private var attempts = 0
        var body: some View {
            Button("Wrong password") { attempts += 1 }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .shake(trigger: attempts)
                .sensoryFeedback(.error, trigger: attempts)
        }
    }
    return Demo()
}
