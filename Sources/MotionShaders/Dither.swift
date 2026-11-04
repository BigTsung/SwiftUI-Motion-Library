import SwiftUI

/// Retro ordered dithering: the view is cut into chunky pixels and drawn in
/// a few flat colours with a Bayer cross-hatch between them, like an old
/// handheld console screen. Rendered with a Metal `layerEffect`
/// (`Shaders/Dither.metal`).
struct DitherModifier: ViewModifier, Animatable {
    var pixelSize: Double
    var palette: [Color]

    nonisolated var animatableData: Double {
        get { pixelSize }
        set { pixelSize = newValue }
    }

    func body(content: Content) -> some View {
        let size = max(1, pixelSize)
        content.layerEffect(
            motionShaders.motionDither(.float(size), .colorArray(palette)),
            maxSampleOffset: CGSize(width: size, height: size),
            isEnabled: palette.count >= 2
        )
    }
}

public extension View {
    /// Draws the view in a handful of colours with ordered (Bayer) dithering.
    ///
    /// ```swift
    /// Image("level")
    ///     .dither(pixelSize: 3)                         // four-shade green
    /// Avatar()
    ///     .dither(pixelSize: 2, palette: [.black, .white]) // 1-bit
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameters:
    ///   - pixelSize: Size of one chunky pixel, in points.
    ///   - palette: Two or more colours from darkest to lightest. The default
    ///     is a four-shade green, like an early handheld console.
    func dither(pixelSize: Double = 3, palette: [Color] = DitherPalette.green) -> some View {
        modifier(DitherModifier(pixelSize: pixelSize, palette: palette))
    }
}

/// Palettes for `.dither(pixelSize:palette:)`, darkest first.
public enum DitherPalette {
    /// Four greens, like an early handheld console's screen.
    public static let green: [Color] = [
        Color(red: 0.06, green: 0.22, blue: 0.06), Color(red: 0.19, green: 0.38, blue: 0.19),
        Color(red: 0.55, green: 0.67, blue: 0.06), Color(red: 0.61, green: 0.74, blue: 0.06),
    ]
    /// Black and white.
    public static let mono: [Color] = [.black, .white]
    /// Four warm browns, like an old photograph.
    public static let sepia: [Color] = [
        Color(red: 0.17, green: 0.11, blue: 0.07), Color(red: 0.44, green: 0.3, blue: 0.2),
        Color(red: 0.75, green: 0.6, blue: 0.43), Color(red: 0.96, green: 0.9, blue: 0.78),
    ]
}

#Preview {
    LinearGradient(colors: [.black, .white], startPoint: .leading, endPoint: .trailing)
        .overlay(Image(systemName: "gamecontroller.fill").font(.system(size: 70)).foregroundStyle(.gray))
        .frame(width: 260, height: 160)
        .dither(pixelSize: 3)
}
