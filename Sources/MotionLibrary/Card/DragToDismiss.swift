import SwiftUI

/// Lets the user fling a view away. While dragging it follows the finger,
/// shrinking and tilting a little; released past a distance (or flicked fast
/// enough) it flies off in the throw direction and `isPresented` turns
/// false; otherwise it springs back.
struct DragToDismissModifier: ViewModifier {
    @Binding var isPresented: Bool
    var threshold: CGFloat

    @State private var drag: CGSize = .zero
    @State private var isLeaving = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        let distance = hypot(drag.width, drag.height)
        content
            .scaleEffect(reduceMotion ? 1 : 1 - min(0.2, distance / 1200))
            .rotationEffect(.degrees(reduceMotion ? 0 : Double(drag.width) / 25))
            .offset(drag)
            .opacity(isLeaving ? 0 : 1)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard !isLeaving else { return }
                        drag = value.translation
                    }
                    .onEnded { value in
                        guard !isLeaving else { return }
                        let predicted = value.predictedEndTranslation
                        let thrown = hypot(predicted.width, predicted.height) > threshold * 2.5
                        if hypot(value.translation.width, value.translation.height) > threshold || thrown {
                            dismiss(towards: predicted)
                        } else {
                            withAnimation(.spring(duration: 0.45, bounce: 0.4)) { drag = .zero }
                        }
                    }
            )
            .accessibilityAction(named: "Dismiss") { isPresented = false }
    }

    private func dismiss(towards predicted: CGSize) {
        let length = max(1, hypot(predicted.width, predicted.height))
        // Keep the throw direction but make sure it leaves the screen.
        let fly = CGSize(width: predicted.width / length * 700, height: predicted.height / length * 700)
        withAnimation(.easeOut(duration: 0.3)) {
            drag = fly
            isLeaving = true
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            isPresented = false
            var reset = Transaction()
            reset.disablesAnimations = true
            withTransaction(reset) {
                drag = .zero
                isLeaving = false
            }
        }
    }
}

public extension View {
    /// Lets the user drag the view away to dismiss it, with a spring back if
    /// they don't drag far enough.
    ///
    /// ```swift
    /// if showPhoto {
    ///     PhotoView()
    ///         .dragToDismiss(isPresented: $showPhoto)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: Set to `false` once the view has flown off.
    ///   - threshold: Drag distance, in points, that dismisses on release.
    func dragToDismiss(isPresented: Binding<Bool>, threshold: CGFloat = 120) -> some View {
        modifier(DragToDismissModifier(isPresented: isPresented, threshold: threshold))
    }
}

#Preview {
    struct Demo: View {
        @State private var shown = true
        var body: some View {
            ZStack {
                if shown {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.indigo.gradient)
                        .frame(width: 220, height: 300)
                        .dragToDismiss(isPresented: $shown)
                } else {
                    Button("Show again") { shown = true }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    return Demo()
}
