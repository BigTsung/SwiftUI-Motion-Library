import SwiftUI

/// Soft, slowly drifting colour blobs, heavily blurred. A calm animated
/// backdrop for onboarding screens, paywalls, or hero sections.
///
/// ```swift
/// ZStack {
///     AuroraBackground()
///         .ignoresSafeArea()
///     Text("Welcome").font(.largeTitle.bold())
/// }
/// ```
public struct AuroraBackground: View {
    private let colors: [Color]
    private let speed: Double
    private let blurRadius: CGFloat
    private let baseColor: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        colors: [Color] = [.purple, .blue, .teal, .pink],
        speed: Double = 1,
        blurRadius: CGFloat = 60,
        baseColor: Color = .black
    ) {
        self.colors = colors
        self.speed = speed * 0.4
        self.blurRadius = blurRadius
        self.baseColor = baseColor
    }

    public var body: some View {
        // Reduce Motion: a still frame of the same blobs.
        TimelineView(.animation(paused: reduceMotion || speed == 0)) { timeline in
            let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate * speed
            GeometryReader { geometry in
                blobs(time: time, size: geometry.size)
            }
        }
        .background(baseColor)
        .clipped()
        .accessibilityHidden(true)
    }

    private func blobs(time: Double, size: CGSize) -> some View {
        ZStack {
            ForEach(colors.indices, id: \.self) { index in
                blob(color: colors[index], index: index, time: time, size: size)
            }
        }
        .frame(width: size.width, height: size.height)
        .blur(radius: blurRadius)
    }

    private func blob(color: Color, index: Int, time: Double, size: CGSize) -> some View {
        let phase = Double(index) * 1.7
        let diameter = max(size.width, size.height) * 0.7
        let x = CGFloat(cos(time * 0.6 + phase)) * size.width * 0.3
        let y = CGFloat(sin(time * 0.8 + phase * 1.3)) * size.height * 0.3
        return Circle()
            .fill(color.opacity(0.8))
            .frame(width: diameter, height: diameter)
            .offset(x: x, y: y)
    }
}

#Preview {
    ZStack {
        AuroraBackground()
            .ignoresSafeArea()
        Text("Welcome")
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
    }
}
