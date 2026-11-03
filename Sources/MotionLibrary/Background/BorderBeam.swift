import SwiftUI

/// A short comet of light that runs around the view's rounded border forever.
struct BorderBeamModifier: ViewModifier {
    var cornerRadius: CGFloat
    var colors: [Color]
    var lineWidth: CGFloat
    var length: CGFloat
    var duration: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.overlay {
            // Reduce Motion: the beam is parked at the top-left corner.
            TimelineView(.animation(paused: reduceMotion)) { timeline in
                let time = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                let head = CGFloat((time / max(0.1, duration)).truncatingRemainder(dividingBy: 1))
                ZStack {
                    beam(head: head).blur(radius: lineWidth * 2)
                    beam(head: head)
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    /// The beam from `head - length` to `head`, split in two when it wraps
    /// past the start of the path.
    private func beam(head: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let tail = head - length
        let style = StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        let gradient = LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
        return ZStack {
            shape.trim(from: max(0, tail), to: head).stroke(gradient, style: style)
            if tail < 0 {
                shape.trim(from: 1 + tail, to: 1).stroke(gradient, style: style)
            }
        }
        .padding(lineWidth / 2)
    }
}

public extension View {
    /// Sends a beam of light around the view's border, forever.
    ///
    /// ```swift
    /// PlanCard()
    ///     .background(.black, in: RoundedRectangle(cornerRadius: 20))
    ///     .borderBeam(cornerRadius: 20)
    /// ```
    ///
    /// - Parameters:
    ///   - cornerRadius: Match the view's own corner radius.
    ///   - colors: Gradient of the beam.
    ///   - lineWidth: Beam thickness, in points.
    ///   - length: Fraction of the border the beam covers (0…1).
    ///   - duration: Seconds per lap.
    func borderBeam(
        cornerRadius: CGFloat = 16,
        colors: [Color] = [.orange, .pink, .purple],
        lineWidth: CGFloat = 2,
        length: CGFloat = 0.2,
        duration: Double = 4
    ) -> some View {
        modifier(BorderBeamModifier(
            cornerRadius: cornerRadius,
            colors: colors,
            lineWidth: lineWidth,
            length: min(1, max(0.01, length)),
            duration: duration
        ))
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color(white: 0.08))
        .frame(width: 240, height: 140)
        .overlay(Text("Pro plan").font(.headline).foregroundStyle(.white))
        .borderBeam(cornerRadius: 20)
        .padding()
}
