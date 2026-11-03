import SwiftUI

/// The view breaks up like a bad signal on its way in or out: horizontal
/// slices jump sideways, red and cyan copies split apart, and it flickers in
/// steps rather than fading smoothly.
public struct GlitchTransition: Transition {
    public var slices: Int

    /// - Parameter slices: Number of horizontal slices that jump around.
    public init(slices: Int = 7) {
        self.slices = max(1, slices)
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        GlitchTransitionBody(content: content, phase: phase, slices: slices)
    }
}

private struct GlitchTransitionBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase
    let slices: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            // Reduce Motion: a plain fade.
            content.opacity(phase.isIdentity ? 1 : 0)
        } else {
            content.modifier(GlitchEffect(amount: phase.isIdentity ? 0 : 1, slices: slices))
        }
    }
}

struct GlitchEffect: ViewModifier, Animatable {
    /// 0 = intact, 1 = gone.
    var amount: Double
    var slices: Int

    var animatableData: Double {
        get { amount }
        set { amount = newValue }
    }

    func body(content: Content) -> some View {
        if amount <= 0.001 {
            content
        } else {
            // The glitch pattern changes in discrete "frames", not smoothly.
            let frame = Int(amount * 16)
            let split = CGFloat(amount) * 10
            // Stepped flicker on the way out.
            let visible = Self.random(frame, 99) > amount * 0.9 ? 1 - amount * 0.6 : 0.15
            ZStack {
                content
                    .colorMultiply(.red)
                    .offset(x: -split)
                    .opacity(0.6)
                content
                    .colorMultiply(.cyan)
                    .offset(x: split)
                    .opacity(0.6)
                ForEach(0..<slices, id: \.self) { slice in
                    content
                        .mask(GlitchSlice(index: slice, count: slices))
                        .offset(x: CGFloat(Self.random(slice, frame) - 0.5) * 60 * CGFloat(amount))
                }
            }
            .compositingGroup()
            .opacity(amount >= 0.999 ? 0 : visible)
            .allowsHitTesting(false)
        }
    }

    static func random(_ a: Int, _ b: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: a &* 73_856_093 ^ b &* 19_349_663)
        x = (x ^ (x >> 33)) &* 0xff51_afd7_ed55_8ccd
        x ^= x >> 33
        return Double(x % 10_000) / 10_000
    }
}

/// One horizontal band of the view.
struct GlitchSlice: Shape {
    var index: Int
    var count: Int

    func path(in rect: CGRect) -> Path {
        let height = rect.height / CGFloat(count)
        return Path(CGRect(x: rect.minX - rect.width, y: rect.minY + CGFloat(index) * height, width: rect.width * 3, height: height + 0.5))
    }
}

public extension Transition where Self == GlitchTransition {
    /// Glitches the view in and out like a broken signal.
    ///
    /// ```swift
    /// if showAlert {
    ///     AlertBanner().transition(.glitch)
    /// }
    /// ```
    static var glitch: GlitchTransition { GlitchTransition() }

    /// Glitches the view in and out with `slices` jumping bands.
    static func glitch(slices: Int) -> GlitchTransition { GlitchTransition(slices: slices) }
}

#Preview {
    struct Demo: View {
        @State private var shown = true
        var body: some View {
            ZStack {
                if shown {
                    Text("SIGNAL")
                        .font(.system(size: 40, weight: .black, design: .monospaced))
                        .padding()
                        .background(Color.black, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                        .transition(.glitch)
                }
            }
            .frame(width: 280, height: 160)
            .onTapGesture { withAnimation(.linear(duration: 0.6)) { shown.toggle() } }
        }
    }
    return Demo()
}
