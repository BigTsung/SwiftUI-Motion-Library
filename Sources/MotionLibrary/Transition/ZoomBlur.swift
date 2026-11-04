import SwiftUI

/// Rushes the view in from the camera with a zoom blur: it arrives large and
/// out of focus, trailed by fading echoes, and snaps sharp as it lands. On
/// removal it flies past the viewer the same way.
public struct ZoomBlurTransition: Transition {
    public var scale: CGFloat

    public init(scale: CGFloat = 1.6) {
        self.scale = scale
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        ZoomBlurBody(content: content, phase: phase, scale: scale)
    }
}

private struct ZoomBlurBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase
    let scale: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let away = phase.isIdentity ? 0.0 : 1.0
        if reduceMotion {
            content.opacity(1 - away)
        } else {
            content.modifier(ZoomBlurEffect(amount: away, scale: scale, content: content))
        }
    }
}

/// The look at `amount` 0 (in place) to 1 (fully zoomed away). The echoes
/// are fainter, larger copies, a cheap stand-in for a radial blur.
private struct ZoomBlurEffect<Echo: View>: ViewModifier, Animatable {
    var amount: Double
    var scale: CGFloat
    let content: Echo

    var animatableData: Double {
        get { amount }
        set { amount = newValue }
    }

    func body(content view: Content) -> some View {
        let a = CGFloat(amount)
        view
            .scaleEffect(1 + (scale - 1) * a)
            .blur(radius: 14 * a)
            .opacity(1 - amount)
            .background {
                if amount > 0.01 && amount < 0.99 {
                    ZStack {
                        ForEach(1...3, id: \.self) { step in
                            content
                                .scaleEffect(1 + (scale - 1) * a + CGFloat(step) * 0.12 * a)
                                .blur(radius: 6 + 6 * CGFloat(step) * a)
                                .opacity((1 - amount) * 0.28 / Double(step))
                        }
                    }
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
    }
}

public extension Transition where Self == ZoomBlurTransition {
    /// Zooms the view in from the camera, blurred and trailed by echoes,
    /// and out past the viewer on removal.
    ///
    /// ```swift
    /// if let photo = selected {
    ///     PhotoView(photo).transition(.zoomBlur)
    /// }
    /// ```
    static var zoomBlur: ZoomBlurTransition { ZoomBlurTransition() }

    /// Zooms the view in from `scale` times its size.
    static func zoomBlur(scale: CGFloat) -> ZoomBlurTransition { ZoomBlurTransition(scale: scale) }
}

#Preview {
    struct Demo: View {
        @State private var shown = true
        var body: some View {
            ZStack {
                if shown {
                    Text("WARP")
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .foregroundStyle(.indigo)
                        .transition(.zoomBlur)
                }
            }
            .frame(width: 280, height: 180)
            .onTapGesture { withAnimation(.easeOut(duration: 0.6)) { shown.toggle() } }
        }
    }
    return Demo()
}
