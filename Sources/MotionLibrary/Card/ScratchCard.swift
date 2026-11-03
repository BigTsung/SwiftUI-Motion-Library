import SwiftUI

/// Covers the view with a scratch-off layer. Dragging a finger erases the
/// cover along its path; once enough of it is scratched away, the rest
/// fades out and `onReveal` runs.
struct ScratchModifier<Cover: ShapeStyle>: ViewModifier {
    var cover: Cover
    var lineWidth: CGFloat
    var threshold: Double
    var onReveal: () -> Void

    @State private var strokes: [[CGPoint]] = []
    @State private var scratched: Set<Int> = []
    @State private var isRevealed = false

    /// The cover is split into a grid to estimate how much has been scratched.
    private let grid = 12

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { geometry in
                Rectangle()
                    .fill(cover)
                    .overlay {
                        Image(systemName: "hand.draw.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.7))
                            .opacity(strokes.isEmpty ? 1 : 0)
                            .animation(.easeOut(duration: 0.2), value: strokes.isEmpty)
                    }
                    .mask {
                        ZStack {
                            Rectangle()
                            ScratchPath(strokes: strokes)
                                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                                .blendMode(.destinationOut)
                        }
                        .compositingGroup()
                    }
                    .opacity(isRevealed ? 0 : 1)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard !isRevealed else { return }
                                if value.translation == .zero || strokes.isEmpty {
                                    strokes.append([value.location])
                                } else {
                                    strokes[strokes.count - 1].append(value.location)
                                }
                                mark(value.location, in: geometry.size)
                            }
                    )
                    .allowsHitTesting(!isRevealed)
            }
            .accessibilityElement()
            .accessibilityLabel("Scratch card")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { reveal() }
            .accessibilityHidden(isRevealed)
        }
    }

    /// Marks every grid cell the brush touches at `point`.
    private func mark(_ point: CGPoint, in size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        let cellW = size.width / CGFloat(grid), cellH = size.height / CGFloat(grid)
        let r = lineWidth / 2
        let minC = max(0, Int((point.x - r) / cellW)), maxC = min(grid - 1, Int((point.x + r) / cellW))
        let minR = max(0, Int((point.y - r) / cellH)), maxR = min(grid - 1, Int((point.y + r) / cellH))
        guard minC <= maxC, minR <= maxR else { return }
        for row in minR...maxR {
            for column in minC...maxC {
                scratched.insert(row * grid + column)
            }
        }
        if Double(scratched.count) / Double(grid * grid) >= threshold {
            reveal()
        }
    }

    private func reveal() {
        guard !isRevealed else { return }
        withAnimation(.easeOut(duration: 0.4)) { isRevealed = true }
        onReveal()
    }
}

struct ScratchPath: Shape {
    var strokes: [[CGPoint]]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for stroke in strokes {
            guard let first = stroke.first else { continue }
            path.move(to: first)
            // A single tap still leaves a round dot.
            path.addLine(to: stroke.count > 1 ? stroke[1] : CGPoint(x: first.x + 0.1, y: first.y))
            if stroke.count > 2 { path.addLines(Array(stroke.dropFirst())) }
        }
        return path
    }
}

public extension View {
    /// Hides the view under a scratch-off cover that the user rubs away.
    ///
    /// ```swift
    /// PrizeView()
    ///     .scratchToReveal(LinearGradient(colors: [.gray, .secondary], startPoint: .top, endPoint: .bottom)) {
    ///         didReveal = true
    ///     }
    /// ```
    ///
    /// Give the view a new `.id` to reset the cover.
    ///
    /// - Parameters:
    ///   - cover: The scratch-off layer's fill.
    ///   - lineWidth: Width of the "coin", in points.
    ///   - threshold: Fraction of the cover to scratch before it clears itself.
    ///   - onReveal: Called once when the cover clears.
    func scratchToReveal<Cover: ShapeStyle>(
        _ cover: Cover = Color.gray,
        lineWidth: CGFloat = 34,
        threshold: Double = 0.55,
        onReveal: @escaping () -> Void = {}
    ) -> some View {
        modifier(ScratchModifier(cover: cover, lineWidth: lineWidth, threshold: threshold, onReveal: onReveal))
    }
}

#Preview {
    VStack(spacing: 6) {
        Text("🎉").font(.system(size: 44))
        Text("You won!").font(.headline)
    }
    .frame(width: 220, height: 140)
    .background(Color.yellow.opacity(0.3))
    .scratchToReveal(LinearGradient(colors: [Color(white: 0.62), Color(white: 0.78)], startPoint: .topLeading, endPoint: .bottomTrailing))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .padding()
}
