import SwiftUI

/// The view develops like an instant photo: it starts as a dark, murky,
/// blue-brown smudge and over a few seconds the light, contrast, colour and
/// focus come in.
struct PhotoDevelopModifier<Trigger: Equatable>: ViewModifier {
    var trigger: Trigger
    var duration: Double

    @State private var progress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .modifier(DevelopEffect(progress: progress))
            .onAppear(perform: develop)
            .onChange(of: trigger) { develop() }
    }

    private func develop() {
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) { progress = 0 }
        withAnimation(reduceMotion ? .easeInOut(duration: 0.4) : .easeOut(duration: duration)) { progress = 1 }
    }
}

/// The look at a point of the development, 0 (blank) to 1 (developed).
/// Animatable, so each quality keeps its own pace during the animation.
struct DevelopEffect: ViewModifier, Animatable {
    var progress: Double

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        // Each quality arrives at its own pace: light first, colour last.
        let light = min(1, progress * 1.6)
        let colour = max(0, (progress - 0.25) / 0.75)
        let focus = min(1, progress * 1.3)
        content
            .saturation(colour)
            .contrast(0.55 + 0.45 * light)
            .brightness(-0.45 * (1 - light))
            .blur(radius: 5 * (1 - focus))
            .overlay {
                // The murky blue-brown cast of an undeveloped print.
                LinearGradient(colors: [Color(red: 0.2, green: 0.25, blue: 0.35), Color(red: 0.35, green: 0.25, blue: 0.18)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .opacity(0.75 * (1 - colour))
                    .blendMode(.multiply)
                    .allowsHitTesting(false)
            }
    }
}

public extension View {
    /// Develops the view like an instant photo on appear, and again whenever
    /// `trigger` changes.
    ///
    /// ```swift
    /// Image("snapshot")
    ///     .resizable()
    ///     .scaledToFill()
    ///     .photoDevelop()
    /// ```
    ///
    /// - Parameters:
    ///   - trigger: Develops the photo again whenever it changes.
    ///   - duration: Seconds from blank to fully developed.
    func photoDevelop(trigger: some Equatable = 0, duration: Double = 3.5) -> some View {
        modifier(PhotoDevelopModifier(trigger: trigger, duration: duration))
    }
}

#Preview {
    struct Demo: View {
        @State private var shots = 0
        var body: some View {
            VStack(spacing: 0) {
                LinearGradient(colors: [.orange, .pink, .purple], startPoint: .top, endPoint: .bottom)
                    .overlay(Image(systemName: "sun.max.fill").font(.system(size: 50)).foregroundStyle(.yellow))
                    .frame(width: 160, height: 160)
                    .photoDevelop(trigger: shots)
                Color.white.frame(height: 40)
            }
            .padding([.top, .horizontal], 10)
            .background(.white)
            .shadow(radius: 6)
            .onTapGesture { shots += 1 }
        }
    }
    return Demo()
}
