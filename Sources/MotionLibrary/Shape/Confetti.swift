import SwiftUI

/// Confetti that bursts up and out of the view whenever `trigger` changes,
/// then tumbles down under gravity and fades. Drawn in a single `Canvas`, so
/// a few hundred pieces stay cheap.
struct ConfettiModifier<Trigger: Equatable>: ViewModifier {
    var trigger: Trigger
    var colors: [Color]
    var count: Int
    var spread: CGFloat

    @State private var bursts: [ConfettiBurst] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                if !bursts.isEmpty {
                    TimelineView(.animation) { timeline in
                        Canvas { context, size in
                            let now = timeline.date
                            for burst in bursts {
                                burst.draw(in: &context, size: size, time: now.timeIntervalSince(burst.start), colors: colors)
                            }
                        }
                    }
                    // Draw well beyond the view's own bounds.
                    .padding(-spread)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
            .onChange(of: trigger) {
                guard !reduceMotion else { return }
                let burst = ConfettiBurst(count: count, spread: spread)
                bursts.append(burst)
                DispatchQueue.main.asyncAfter(deadline: .now() + ConfettiBurst.lifetime) {
                    bursts.removeAll { $0.id == burst.id }
                }
            }
    }
}

struct ConfettiBurst: Identifiable {
    static let lifetime: Double = 2.4

    struct Piece {
        var velocity: CGVector
        var spin: Double
        var wobble: Double
        var size: CGSize
        var colorIndex: Int
        var isCircle: Bool
    }

    let id = UUID()
    let start = Date()
    let pieces: [Piece]

    init(count: Int, spread: CGFloat) {
        pieces = (0..<max(1, count)).map { index in
            // Mostly upward, fanned out ±60° from vertical.
            let angle = -Double.pi / 2 + Double.random(in: -1.05...1.05)
            let speed = Double.random(in: 0.55...1.0) * Double(spread) * 3.2
            return Piece(
                velocity: CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed),
                spin: Double.random(in: -9...9),
                wobble: Double.random(in: 0...(2 * .pi)),
                size: CGSize(width: .random(in: 5...9), height: .random(in: 8...14)),
                colorIndex: index,
                isCircle: index.isMultiple(of: 4)
            )
        }
    }

    func draw(in context: inout GraphicsContext, size: CGSize, time: Double, colors: [Color]) {
        guard time >= 0, time < Self.lifetime, !colors.isEmpty else { return }
        let origin = CGPoint(x: size.width / 2, y: size.height / 2)
        let gravity = 900.0
        let drag = 1.6
        // Velocity decays with air drag; position integrates it.
        let decay = (1 - exp(-drag * time)) / drag
        let fade = time > Self.lifetime - 0.6 ? (Self.lifetime - time) / 0.6 : 1
        for piece in pieces {
            let x = origin.x + piece.velocity.dx * decay
            let y = origin.y + piece.velocity.dy * decay + 0.5 * gravity * time * time * 0.55
            var copy = context
            copy.opacity = fade
            copy.translateBy(x: x, y: y)
            copy.rotate(by: .radians(piece.spin * time))
            // Squash horizontally to fake the piece turning over in 3D.
            copy.scaleBy(x: CGFloat(cos(piece.wobble + time * 8)), y: 1)
            let rect = CGRect(
                x: -piece.size.width / 2,
                y: -piece.size.height / 2,
                width: piece.size.width,
                height: piece.isCircle ? piece.size.width : piece.size.height
            )
            let shape = piece.isCircle ? Path(ellipseIn: rect) : Path(rect)
            copy.fill(shape, with: .color(colors[piece.colorIndex % colors.count]))
        }
    }
}

public extension View {
    /// Fires a confetti burst from the view each time `trigger` changes.
    ///
    /// ```swift
    /// Button("Complete order") { orders += 1 }
    ///     .confetti(trigger: orders)
    /// ```
    ///
    /// - Parameters:
    ///   - trigger: Any equatable value; each change fires one burst.
    ///   - colors: Colours the pieces cycle through.
    ///   - count: Pieces per burst.
    ///   - spread: How far beyond the view's bounds confetti may travel.
    func confetti<Trigger: Equatable>(
        trigger: Trigger,
        colors: [Color] = [.pink, .orange, .yellow, .green, .blue, .purple],
        count: Int = 80,
        spread: CGFloat = 160
    ) -> some View {
        modifier(ConfettiModifier(trigger: trigger, colors: colors, count: count, spread: spread))
    }
}

#Preview {
    struct Demo: View {
        @State private var count = 0

        var body: some View {
            Button("Celebrate 🎉") { count += 1 }
                .buttonStyle(.borderedProminent)
                .confetti(trigger: count)
                .frame(width: 400, height: 400)
        }
    }
    return Demo()
}
