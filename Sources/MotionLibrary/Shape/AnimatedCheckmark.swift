import SwiftUI

/// A success mark that draws itself: the circle strokes around, fills, then
/// the checkmark is drawn on top with a small pop. Unchecking erases it.
public struct AnimatedCheckmark: View {
    private let isChecked: Bool
    private let color: Color
    private let lineWidth: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - isChecked: Draws the mark when true, erases it when false.
    ///   - color: Circle colour; the checkmark is white on top of it.
    ///   - lineWidth: Stroke width, scaled with the view's size (at 60 pt).
    public init(isChecked: Bool, color: Color = .green, lineWidth: CGFloat = 4) {
        self.isChecked = isChecked
        self.color = color
        self.lineWidth = lineWidth
    }

    public var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let scale = side / 60
            ZStack {
                Circle()
                    .trim(from: 0, to: isChecked ? 1 : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth * scale, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(timing(.easeInOut(duration: 0.45)), value: isChecked)
                Circle()
                    .fill(color)
                    .scaleEffect(isChecked ? 1 : 0.6)
                    .opacity(isChecked ? 1 : 0)
                    .animation(timing(.spring(response: 0.35, dampingFraction: 0.6).delay(isChecked ? 0.35 : 0)), value: isChecked)
                CheckmarkShape()
                    .trim(from: 0, to: isChecked ? 1 : 0)
                    .stroke(.white, style: StrokeStyle(lineWidth: lineWidth * 1.2 * scale, lineCap: .round, lineJoin: .round))
                    .frame(width: side * 0.42, height: side * 0.32)
                    .offset(y: side * 0.02)
                    .animation(timing(.easeOut(duration: 0.3).delay(isChecked ? 0.55 : 0)), value: isChecked)
            }
            .frame(width: side, height: side)
            .scaleEffect(isChecked && !reduceMotion ? 1 : 0.95)
            .animation(timing(.spring(response: 0.3, dampingFraction: 0.4).delay(isChecked ? 0.75 : 0)), value: isChecked)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel(isChecked ? Text("Done") : Text("Not done"))
    }

    /// Reduce Motion: skip the drawing and just fade.
    private func timing(_ animation: Animation) -> Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : animation
    }
}

#Preview {
    struct Demo: View {
        @State private var checked = false

        var body: some View {
            AnimatedCheckmark(isChecked: checked)
                .frame(width: 80, height: 80)
                .onTapGesture { checked.toggle() }
        }
    }
    return Demo()
}
