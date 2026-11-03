import SwiftUI

/// Breaks the view into square blocks of one colour each. The block size is
/// animatable, so the view can melt into or out of a mosaic. Rendered with a
/// Metal `layerEffect` (`Shaders/Pixellate.metal`).
struct PixellateModifier: ViewModifier, Animatable {
    var size: Double

    var animatableData: Double {
        get { size }
        set { size = newValue }
    }

    func body(content: Content) -> some View {
        content.layerEffect(
            motionShaders.motionPixellate(.float(size)),
            maxSampleOffset: CGSize(width: size, height: size),
            isEnabled: size > 1
        )
    }
}

public extension View {
    /// Shows the view as a mosaic of `size`-point blocks. Animate `size`
    /// to pixellate in or out.
    ///
    /// ```swift
    /// Avatar()
    ///     .pixellate(isHidden ? 18 : 1)
    ///     .animation(.easeInOut, value: isHidden)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameter size: Block size in points; 1 or less shows the view as is.
    func pixellate(_ size: Double) -> some View {
        modifier(PixellateModifier(size: size))
    }
}

#Preview {
    struct Demo: View {
        @State private var blocky = false
        var body: some View {
            Image(systemName: "photo.artframe")
                .font(.system(size: 120))
                .foregroundStyle(.orange, .blue)
                .pixellate(blocky ? 16 : 1)
                .onTapGesture { withAnimation(.easeInOut(duration: 0.8)) { blocky.toggle() } }
        }
    }
    return Demo()
}
