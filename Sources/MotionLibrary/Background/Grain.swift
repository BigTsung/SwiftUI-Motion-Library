import CoreGraphics
import SwiftUI

/// Film grain: a tiled noise texture over the view, re-positioned a few times
/// a second so it flickers like real film.
struct GrainModifier: ViewModifier {
    var opacity: Double
    var isAnimated: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.overlay {
            if let noise = NoiseTexture.image {
                // Reduce Motion: still grain.
                let animated = isAnimated && !reduceMotion
                TimelineView(.periodic(from: .now, by: 1.0 / 12)) { timeline in
                    let frame = animated ? Int(timeline.date.timeIntervalSinceReferenceDate * 12) : 0
                    GeometryReader { geometry in
                        Image(decorative: noise, scale: 2)
                            .resizable(resizingMode: .tile)
                            // One tile larger than the view in each direction so
                            // the random shift never uncovers an edge.
                            .frame(width: geometry.size.width + 64, height: geometry.size.height + 64)
                            .offset(x: -CGFloat(frame * 37 % 64), y: -CGFloat(frame * 53 % 64))
                    }
                    .clipped()
                }
                .blendMode(.overlay)
                .opacity(opacity)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
        }
    }
}

/// A 128×128 grey noise image, generated once.
enum NoiseTexture {
    static let image: CGImage? = {
        let side = 128
        var generator = SplitMix64(seed: 7)
        var pixels = [UInt8](repeating: 0, count: side * side)
        for index in pixels.indices {
            pixels[index] = UInt8(truncatingIfNeeded: generator.next() >> 56)
        }
        guard let provider = CGDataProvider(data: Data(pixels) as CFData) else { return nil }
        return CGImage(
            width: side,
            height: side,
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            bytesPerRow: side,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
    }()
}

public extension View {
    /// Lays flickering film grain over the view.
    ///
    /// ```swift
    /// LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
    ///     .grain()
    ///
    /// HeroImage()
    ///     .grain(opacity: 0.25, isAnimated: false)
    /// ```
    ///
    /// - Parameters:
    ///   - opacity: Strength of the grain (0…1).
    ///   - isAnimated: Re-rolls the grain 12 times a second when true.
    func grain(opacity: Double = 0.35, isAnimated: Bool = true) -> some View {
        modifier(GrainModifier(opacity: opacity, isAnimated: isAnimated))
    }
}

#Preview {
    LinearGradient(colors: [.orange, .pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        .grain()
        .frame(width: 300, height: 200)
}
