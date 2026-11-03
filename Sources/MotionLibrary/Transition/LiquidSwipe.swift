import SwiftUI

/// The incoming view pours in from the trailing edge behind a liquid wave
/// with a bulge in the middle, covering the outgoing view, which darkens
/// slightly as it disappears. Great for onboarding pages.
public struct LiquidSwipeTransition: Transition {
    public init() {}

    public func body(content: Content, phase: TransitionPhase) -> some View {
        LiquidSwipeBody(content: content, phase: phase)
    }
}

private struct LiquidSwipeBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        content
            .mask {
                LiquidEdge(progress: phase == .willAppear ? 0 : 1, bulge: reduceMotion ? 0 : 1)
            }
            .brightness(phase == .didDisappear ? -0.15 : 0)
            // The incoming page always draws on top of the outgoing one.
            .zIndex(phase == .didDisappear ? 0 : 1)
    }
}

/// Covers the view from the trailing edge; the leading edge of the covered
/// area is a wave whose bulge peaks halfway through.
struct LiquidEdge: Shape {
    var progress: Double
    var bulge: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard progress < 1 else { return Path(rect) }
        var path = Path()
        guard progress > 0 else { return path }
        let p = CGFloat(progress)
        let amplitude = rect.width * 0.35 * CGFloat(sin(progress * .pi) * bulge)
        // The straight part of the edge, pushed far enough left that the
        // bulge has fully left the view by the end.
        let edge = rect.maxX - (rect.width + amplitude) * p
        let midY = rect.midY
        let reach = rect.height * 0.45
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: edge, y: rect.minY))
        path.addLine(to: CGPoint(x: edge, y: midY - reach))
        path.addCurve(
            to: CGPoint(x: edge - amplitude, y: midY),
            control1: CGPoint(x: edge, y: midY - reach * 0.45),
            control2: CGPoint(x: edge - amplitude, y: midY - reach * 0.5)
        )
        path.addCurve(
            to: CGPoint(x: edge, y: midY + reach),
            control1: CGPoint(x: edge - amplitude, y: midY + reach * 0.5),
            control2: CGPoint(x: edge, y: midY + reach * 0.45)
        )
        path.addLine(to: CGPoint(x: edge, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

public extension Transition where Self == LiquidSwipeTransition {
    /// Pours the new view in from the trailing edge behind a liquid wave.
    ///
    /// ```swift
    /// ZStack {
    ///     OnboardingPage(page)
    ///         .id(page)
    ///         .transition(.liquidSwipe)
    /// }
    /// ```
    static var liquidSwipe: LiquidSwipeTransition { LiquidSwipeTransition() }
}

#Preview {
    struct Demo: View {
        @State private var page = 0
        let colors: [Color] = [.pink, .orange, .teal, .indigo]
        var body: some View {
            ZStack {
                colors[page]
                    .overlay(Text("Page \(page + 1)").font(.largeTitle.bold()).foregroundStyle(.white))
                    .id(page)
                    .transition(.liquidSwipe)
            }
            .frame(width: 260, height: 360)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .onTapGesture { withAnimation(.easeInOut(duration: 0.9)) { page = (page + 1) % colors.count } }
        }
    }
    return Demo()
}
