import SwiftUI

/// The view folds up like a paper map: it's split into horizontal panels
/// that crease in alternating directions and collapse towards the top, with
/// the panels facing away shaded darker. Insertion unfolds it again.
public struct OrigamiTransition: Transition {
    public var folds: Int

    /// - Parameter folds: Number of panels (2…8 looks right).
    public init(folds: Int = 4) {
        self.folds = max(2, folds)
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        OrigamiBody(content: content, phase: phase, folds: folds)
    }
}

private struct OrigamiBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase
    let folds: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            // Reduce Motion: a plain fade.
            content.opacity(phase.isIdentity ? 1 : 0)
        } else {
            content.modifier(OrigamiEffect(progress: phase.isIdentity ? 0 : 1, folds: folds))
        }
    }
}

struct OrigamiEffect: ViewModifier, Animatable {
    /// 0 = flat, 1 = folded away.
    var progress: Double
    var folds: Int

    nonisolated var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        if progress <= 0.001 {
            content
        } else {
            // Keep the original footprint while panels are drawn on top.
            content
                .hidden()
                .overlay(alignment: .top) {
                    GeometryReader { geometry in
                        let panel = geometry.size.height / CGFloat(folds)
                        let angle = 90 * min(progress, 0.999)
                        let c = CGFloat(cos(angle * .pi / 180))
                        ZStack(alignment: .top) {
                            ForEach(0..<folds, id: \.self) { index in
                                let even = index.isMultiple(of: 2)
                                // Even panels hinge on their top edge, odd ones on their bottom edge,
                                // and each is moved up so it starts where the previous one ends.
                                let hinge = CGFloat(even ? index : index + 1)
                                let shift = hinge * panel * (c - 1)
                                content
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .mask(GlitchSlice(index: index, count: folds))
                                    .overlay {
                                        Color.black
                                            .opacity((even ? 0.1 : 0.4) * (1 - Double(c)))
                                            .mask(GlitchSlice(index: index, count: folds))
                                            .allowsHitTesting(false)
                                    }
                                    .rotation3DEffect(
                                        .degrees(even ? angle : -angle),
                                        axis: (x: 1, y: 0, z: 0),
                                        anchor: UnitPoint(x: 0.5, y: hinge / CGFloat(folds)),
                                        perspective: 0.4
                                    )
                                    .offset(y: shift)
                            }
                        }
                    }
                }
                .opacity(progress > 0.85 ? (1 - progress) / 0.15 : 1)
                .allowsHitTesting(false)
        }
    }
}

public extension Transition where Self == OrigamiTransition {
    /// Folds the view up like a paper map (and unfolds it on insertion).
    ///
    /// ```swift
    /// if showTicket {
    ///     TicketView().transition(.origami)
    /// }
    /// ```
    static var origami: OrigamiTransition { OrigamiTransition() }

    /// Folds the view into `folds` panels.
    static func origami(folds: Int) -> OrigamiTransition { OrigamiTransition(folds: folds) }
}

#Preview {
    struct Demo: View {
        @State private var shown = true
        var body: some View {
            ZStack(alignment: .top) {
                if shown {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom))
                        .frame(width: 200, height: 240)
                        .transition(.origami)
                }
            }
            .frame(width: 280, height: 300)
            .onTapGesture { withAnimation(.easeInOut(duration: 0.9)) { shown.toggle() } }
        }
    }
    return Demo()
}
