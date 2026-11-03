import SwiftUI

/// Strokes any `Shape` as if a pen were drawing it, from the start of its
/// path to the end. Draws on appear and whenever `isDrawn` turns on; erases
/// back when it turns off.
public struct DrawOnShape<S: Shape>: View {
    private let shape: S
    private let isDrawn: Bool
    private let style: AnyShapeStyle
    private let lineWidth: CGFloat
    private let duration: Double

    @State private var progress: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(shape: S, isDrawn: Bool, style: AnyShapeStyle, lineWidth: CGFloat, duration: Double) {
        self.shape = shape
        self.isDrawn = isDrawn
        self.style = style
        self.lineWidth = lineWidth
        self.duration = duration
    }

    public var body: some View {
        shape
            .trim(from: 0, to: progress)
            .stroke(style, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            .padding(lineWidth / 2)
            .onAppear { update(isDrawn) }
            .onChange(of: isDrawn) { _, newValue in update(newValue) }
    }

    private func update(_ drawn: Bool) {
        // Reduce Motion: the stroke appears all at once.
        withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .easeInOut(duration: duration)) {
            progress = drawn ? 1 : 0
        }
    }
}

public extension Shape {
    /// Draws the shape's outline like a pen stroke.
    ///
    /// ```swift
    /// Circle()
    ///     .drawOn()
    ///     .frame(width: 80, height: 80)
    ///
    /// SignaturePath()
    ///     .drawOn(isDrawn: signed, style: .blue, lineWidth: 3, duration: 1.6)
    /// ```
    ///
    /// - Parameters:
    ///   - isDrawn: Draws when true, erases when false.
    ///   - style: Stroke colour or gradient.
    ///   - lineWidth: Stroke width, in points.
    ///   - duration: Time to draw the whole path, in seconds.
    @MainActor
    func drawOn<Style: ShapeStyle>(
        isDrawn: Bool = true,
        style: Style = Color.accentColor,
        lineWidth: CGFloat = 3,
        duration: Double = 1.2
    ) -> DrawOnShape<Self> {
        DrawOnShape(shape: self, isDrawn: isDrawn, style: AnyShapeStyle(style), lineWidth: lineWidth, duration: duration)
    }
}

#Preview {
    HStack(spacing: 24) {
        Circle().drawOn().frame(width: 70, height: 70)
        RoundedRectangle(cornerRadius: 14).drawOn(style: .pink, duration: 2).frame(width: 90, height: 70)
    }
    .padding()
}
