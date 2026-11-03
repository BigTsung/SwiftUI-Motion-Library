import SwiftUI

/// Like turning a page in a book: the outgoing view swings away around its
/// leading edge in 3D, shading as it turns, and reveals the incoming view
/// underneath, which brightens up from the page's shadow.
public struct PageTurnTransition: Transition {
    public init() {}

    public func body(content: Content, phase: TransitionPhase) -> some View {
        PageTurnBody(content: content, phase: phase)
    }
}

private struct PageTurnBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        content
            .modifier(PageTurnEffect(progress: phase == .didDisappear ? 1 : 0, reduceMotion: reduceMotion))
            .brightness(phase == .willAppear ? -0.25 : 0)
            // The turning page is on top of the one it reveals.
            .zIndex(phase == .didDisappear ? 1 : 0)
    }
}

struct PageTurnEffect: ViewModifier, Animatable {
    var progress: Double
    var reduceMotion: Bool

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        if reduceMotion {
            // Reduce Motion: fade the page away.
            content.opacity(1 - progress)
        } else {
            content
                .overlay {
                    // The page darkens towards its free edge as it turns.
                    LinearGradient(colors: [.black.opacity(0), .black.opacity(0.45 * progress)], startPoint: .leading, endPoint: .trailing)
                        .allowsHitTesting(false)
                }
                .rotation3DEffect(.degrees(-90 * progress), axis: (x: 0, y: 1, z: 0), anchor: .leading, perspective: 0.6)
                .shadow(color: .black.opacity(0.3 * sin(progress * .pi)), radius: 12, x: 6)
                .opacity(progress > 0.98 ? 0 : 1)
        }
    }
}

public extension Transition where Self == PageTurnTransition {
    /// Turns the old view away like a book page, revealing the new one.
    ///
    /// ```swift
    /// ZStack {
    ///     ChapterView(chapter)
    ///         .id(chapter)
    ///         .transition(.pageTurn)
    /// }
    /// ```
    static var pageTurn: PageTurnTransition { PageTurnTransition() }
}

#Preview {
    struct Demo: View {
        @State private var page = 0
        let colors: [Color] = [.orange, .teal, .indigo]
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(colors[page].gradient)
                    .overlay(Text("Chapter \(page + 1)").font(.title.bold()).foregroundStyle(.white))
                    .id(page)
                    .transition(.pageTurn)
            }
            .frame(width: 220, height: 300)
            .onTapGesture { withAnimation(.easeInOut(duration: 0.9)) { page = (page + 1) % colors.count } }
        }
    }
    return Demo()
}
