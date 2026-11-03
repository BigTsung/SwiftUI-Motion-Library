import SwiftUI

/// Swaps content with a circle that grows from a point (typically where the
/// user tapped) until it covers everything, like switching to dark mode by
/// "painting" it in. The old content stays underneath until it's covered.
public struct CircularReveal<Value: Equatable, Content: View>: View {
    private let value: Value
    private let origin: UnitPoint
    private let duration: Double
    private let content: (Value) -> Content

    @State private var shown: Value
    @State private var incoming: Value?
    @State private var progress: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - value: Whenever it changes, the content for the new value is revealed.
    ///   - origin: Where the circle starts, in unit coordinates. Convert a tap
    ///     location with `UnitPoint(x: x / width, y: y / height)`.
    ///   - duration: Seconds for the circle to cover the view.
    ///   - content: Builds the content for a value.
    public init(value: Value, origin: UnitPoint = .center, duration: Double = 0.7, @ViewBuilder content: @escaping (Value) -> Content) {
        self.value = value
        self.origin = origin
        self.duration = duration
        self.content = content
        _shown = State(initialValue: value)
    }

    public var body: some View {
        ZStack {
            content(shown)
            if let incoming {
                content(incoming)
                    .mask {
                        RevealCircle(progress: reduceMotion ? 1 : progress, origin: origin)
                    }
                    .opacity(reduceMotion ? progress : 1)
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: value) { _, new in reveal(new) }
    }

    private func reveal(_ new: Value) {
        // A reveal in flight finishes instantly so the next one starts clean.
        if let current = incoming { shown = current }
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) {
            incoming = new
            progress = 0
        }
        withAnimation(reduceMotion ? .easeInOut(duration: 0.3) : .easeInOut(duration: duration)) {
            progress = 1
        } completion: {
            guard incoming == new else { return }
            var settle = Transaction()
            settle.disablesAnimations = true
            withTransaction(settle) {
                shown = new
                incoming = nil
            }
        }
    }
}

/// A circle around `origin` whose radius reaches the furthest corner at 1.
struct RevealCircle: Shape {
    var progress: Double
    var origin: UnitPoint

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let o = CGPoint(x: rect.minX + rect.width * origin.x, y: rect.minY + rect.height * origin.y)
        let corners = [CGPoint(x: rect.minX, y: rect.minY), CGPoint(x: rect.maxX, y: rect.minY), CGPoint(x: rect.minX, y: rect.maxY), CGPoint(x: rect.maxX, y: rect.maxY)]
        let reach = corners.map { hypot($0.x - o.x, $0.y - o.y) }.max() ?? 0
        let r = reach * progress
        return Path(ellipseIn: CGRect(x: o.x - r, y: o.y - r, width: r * 2, height: r * 2))
    }
}

#Preview {
    struct Demo: View {
        @State private var dark = false
        @State private var origin = UnitPoint.center
        var body: some View {
            GeometryReader { geometry in
                CircularReveal(value: dark, origin: origin) { isDark in
                    ZStack {
                        isDark ? Color.black : Color.white
                        Image(systemName: isDark ? "moon.stars.fill" : "sun.max.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(isDark ? .yellow : .orange)
                    }
                }
                .onTapGesture { location in
                    origin = UnitPoint(x: location.x / geometry.size.width, y: location.y / geometry.size.height)
                    dark.toggle()
                }
            }
        }
    }
    return Demo()
}
