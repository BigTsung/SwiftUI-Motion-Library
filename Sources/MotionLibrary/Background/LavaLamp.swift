import SwiftUI

/// A lava lamp: soft blobs drift up and down, stretching and merging when
/// they meet. The blobs are blurred and cut back with an alpha threshold
/// (metaballs), then used as a mask over a gradient.
public struct LavaLamp: View {
    private let colors: [Color]
    private let background: Color
    private let blobs: Int
    private let speed: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - colors: Gradient of the wax, top to bottom.
    ///   - background: Colour behind the wax.
    ///   - blobs: Number of blobs.
    ///   - speed: Multiplier on the drifting speed.
    public init(colors: [Color] = [.yellow, .orange, .pink], background: Color = Color(red: 0.16, green: 0.05, blue: 0.25), blobs: Int = 7, speed: Double = 1) {
        self.colors = colors
        self.background = background
        self.blobs = max(1, blobs)
        self.speed = speed
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            // Reduce Motion: a still frame.
            let time = reduceMotion ? 12 : timeline.date.timeIntervalSinceReferenceDate * speed
            LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
                .mask {
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.5, color: .black))
                        context.addFilter(.blur(radius: min(size.width, size.height) * 0.07))
                        context.drawLayer { layer in
                            let unit = min(size.width, size.height)
                            for index in 0..<blobs {
                                let seed = Double(index) * 1.618
                                let x = size.width * (0.2 + 0.6 * (0.5 + 0.5 * sin(seed * 3.1 + time * 0.13)))
                                let y = size.height * (0.5 + 0.48 * sin(time * (0.18 + 0.05 * Double(index % 3)) + seed * 2.3))
                                let r = unit * (0.11 + 0.07 * (0.5 + 0.5 * sin(seed * 5.7)))
                                // Blobs stretch vertically while they move fastest.
                                let stretch = 1 + 0.25 * abs(cos(time * 0.2 + seed * 2.3))
                                layer.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r * stretch, width: r * 2, height: r * 2 * stretch)), with: .color(.black))
                            }
                            // Pools of wax at the bottom and top of the lamp.
                            layer.fill(Path(ellipseIn: CGRect(x: -size.width * 0.1, y: size.height * 0.9, width: size.width * 1.2, height: size.height * 0.3)), with: .color(.black))
                            layer.fill(Path(ellipseIn: CGRect(x: size.width * 0.1, y: -size.height * 0.22, width: size.width * 0.8, height: size.height * 0.28)), with: .color(.black))
                        }
                    }
                }
                .background(background)
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    LavaLamp()
        .frame(width: 200, height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 30))
}
