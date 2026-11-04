import SwiftUI

/// Reveals the view like ink dropped on wet paper: a blot spreads from a
/// point with a blotchy, organic edge until it covers everything.
public struct InkBleedTransition: Transition {
    public var origin: UnitPoint

    public init(origin: UnitPoint = .center) {
        self.origin = origin
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        InkBleedBody(content: content, progress: phase.isIdentity ? 1 : 0, origin: origin)
    }
}

private struct InkBleedBody<Content: View>: View {
    let content: Content
    let progress: Double
    let origin: UnitPoint

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            content.opacity(progress)
        } else {
            content.mask { InkBlot(progress: progress, origin: origin) }
        }
    }
}

/// The blot: a circle ringed by smaller circles, merged into one ragged
/// shape by blurring and thresholding the alpha.
struct InkBlot: View, Animatable {
    var progress: Double
    var origin: UnitPoint

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    var body: some View {
        Canvas { context, size in
            let o = CGPoint(x: size.width * origin.x, y: size.height * origin.y)
            let corners = [CGPoint.zero, CGPoint(x: size.width, y: 0), CGPoint(x: 0, y: size.height), CGPoint(x: size.width, y: size.height)]
            let reach = corners.map { hypot($0.x - o.x, $0.y - o.y) }.max() ?? 0
            // Overshoot so the ragged edge clears the corners at 1.
            let r = (reach * 1.25 + 30) * progress
            guard r > 0.5 else { return }
            context.addFilter(.alphaThreshold(min: 0.5))
            context.addFilter(.blur(radius: max(2, r * 0.06)))
            context.drawLayer { layer in
                layer.fill(Path(ellipseIn: CGRect(x: o.x - r * 0.82, y: o.y - r * 0.82, width: r * 1.64, height: r * 1.64)), with: .color(.black))
                for index in 0..<26 {
                    let angle = Double(index) / 26 * 2 * .pi + Self.hash(index, 1) * 0.4
                    let distance = r * (0.62 + 0.3 * Self.hash(index, 2))
                    let blob = r * (0.12 + 0.2 * Self.hash(index, 3))
                    let c = CGPoint(x: o.x + cos(angle) * distance, y: o.y + sin(angle) * distance)
                    layer.fill(Path(ellipseIn: CGRect(x: c.x - blob, y: c.y - blob, width: blob * 2, height: blob * 2)), with: .color(.black))
                }
            }
        }
    }

    private static func hash(_ a: Int, _ b: Int) -> Double {
        var x = UInt64(truncatingIfNeeded: a &* 73_856_093 ^ b &* 19_349_663 &+ 0x1A4B)
        x = (x ^ (x >> 33)) &* 0xff51_afd7_ed55_8ccd
        x ^= x >> 33
        return Double(x % 10_000) / 10_000
    }
}

public extension Transition where Self == InkBleedTransition {
    /// Spreads the view in (and out) like a blot of ink on wet paper.
    ///
    /// ```swift
    /// if showsDetail {
    ///     DetailCard().transition(.inkBleed)
    /// }
    /// ```
    static var inkBleed: InkBleedTransition { InkBleedTransition() }

    /// Spreads the view in from `origin` like a blot of ink.
    static func inkBleed(from origin: UnitPoint) -> InkBleedTransition { InkBleedTransition(origin: origin) }
}

#Preview {
    struct Demo: View {
        @State private var shown = true
        var body: some View {
            ZStack {
                Color(white: 0.95)
                if shown {
                    LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom)
                        .overlay(Text("Ink").font(.largeTitle.bold()).foregroundStyle(.white))
                        .transition(.inkBleed(from: .topLeading))
                }
            }
            .frame(width: 280, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onTapGesture { withAnimation(.easeInOut(duration: 1.1)) { shown.toggle() } }
        }
    }
    return Demo()
}
