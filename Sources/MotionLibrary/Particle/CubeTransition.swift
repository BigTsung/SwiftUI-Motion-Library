import SwiftUI

/// A 3D cube turn between two views: the outgoing view folds away on one
/// face of a cube while the incoming view rotates in on the next face.
/// Use it on views swapped with an `.id` or an `if`, inside a container
/// that clips.
public struct CubeTransition: Transition {
    /// The side the incoming view enters from.
    public var edge: HorizontalEdge

    public init(edge: HorizontalEdge = .trailing) {
        self.edge = edge
    }

    public func body(content: Content, phase: TransitionPhase) -> some View {
        CubeBody(content: content, phase: phase, edge: edge)
    }
}

private struct CubeBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase
    let edge: HorizontalEdge

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Reduce Motion: a cross-fade.
        let reduceMotion = reduceMotion
        // -1 = fully gone to the leading side, 0 = in place, 1 = waiting on the trailing side.
        let sign: Double = edge == .trailing ? 1 : -1
        let position: Double = switch phase {
        case .willAppear: sign
        case .identity: 0
        case .didDisappear: -sign
        }
        return content
            .visualEffect { effect, proxy in
                let width = proxy.size.width
                return effect
                    .offset(x: reduceMotion ? 0 : width * position)
                    .rotation3DEffect(
                        .degrees(reduceMotion ? 0 : 90 * position),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: position > 0 ? .leading : .trailing,
                        perspective: 0.5
                    )
            }
            .opacity(reduceMotion ? (phase.isIdentity ? 1 : 0) : 1)
    }
}

public extension Transition where Self == CubeTransition {
    /// Turns a cube: the new view rotates in from the trailing side.
    ///
    /// ```swift
    /// ZStack {
    ///     PageView(page)
    ///         .id(page)
    ///         .transition(.cube)
    /// }
    /// .clipped()
    /// ```
    static var cube: CubeTransition { CubeTransition() }

    /// Turns a cube with the new view entering from `edge`.
    static func cube(edge: HorizontalEdge) -> CubeTransition { CubeTransition(edge: edge) }
}

#Preview {
    struct Demo: View {
        @State private var page = 0
        let colors: [Color] = [.pink, .orange, .teal, .indigo]
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(colors[page].gradient)
                    .overlay(Text("\(page + 1)").font(.largeTitle.bold()).foregroundStyle(.white))
                    .id(page)
                    .transition(.cube)
            }
            .frame(width: 200, height: 140)
            .onTapGesture { withAnimation(.easeInOut(duration: 0.7)) { page = (page + 1) % colors.count } }
        }
    }
    return Demo()
}
