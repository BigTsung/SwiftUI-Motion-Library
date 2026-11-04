import SwiftUI

/// A round glass lens over the view: it magnifies what's under it, bends the
/// light harder towards the rim with a hint of colour fringing, and casts a
/// soft shadow. Rendered with a Metal `layerEffect`
/// (`Shaders/GlassLens.metal`).
struct GlassLensModifier: ViewModifier {
    var centre: CGPoint
    var radius: Double
    var magnification: Double

    func body(content: Content) -> some View {
        content.layerEffect(
            motionShaders.motionGlassLens(.float2(centre), .float(radius), .float(max(1, magnification))),
            maxSampleOffset: CGSize(width: radius, height: radius)
        )
    }
}

/// A lens that follows a dragging finger or the pointer.
struct GlassLensOnDragModifier: ViewModifier {
    var radius: Double
    var magnification: Double

    @State private var centre: CGPoint?
    @State private var size: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .modifier(GlassLensModifier(centre: centre ?? CGPoint(x: size.width / 2, y: size.height / 2), radius: radius, magnification: magnification))
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { size = proxy.size }
                        .onChange(of: proxy.size) { _, new in size = new }
                }
            }
            .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                withAnimation(.interactiveSpring(duration: 0.2)) { centre = value.location }
            })
            .onContinuousHover { phase in
                if case let .active(location) = phase { centre = location }
            }
    }
}

public extension View {
    /// Puts a glass lens over the view at `centre`.
    ///
    /// ```swift
    /// MapView()
    ///     .glassLens(at: point, radius: 60)
    /// ```
    ///
    /// Requires the `MotionShaders` product (Metal).
    ///
    /// - Parameters:
    ///   - centre: Centre of the lens, in the view's coordinates.
    ///   - radius: Radius of the lens, in points.
    ///   - magnification: Zoom at the middle of the lens.
    func glassLens(at centre: CGPoint, radius: Double = 56, magnification: Double = 1.8) -> some View {
        modifier(GlassLensModifier(centre: centre, radius: radius, magnification: magnification))
    }

    /// Puts a glass lens over the view that follows a dragging finger or the
    /// pointer. It starts in the middle.
    ///
    /// ```swift
    /// Text(article).glassLensOnDrag()
    /// ```
    func glassLensOnDrag(radius: Double = 56, magnification: Double = 1.8) -> some View {
        modifier(GlassLensOnDragModifier(radius: radius, magnification: magnification))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 6) {
        ForEach(0..<6) { _ in
            Text("Drag the lens over this text to read it.").font(.caption)
        }
    }
    .padding()
    .frame(width: 280, height: 180)
    .background(.white)
    .glassLensOnDrag()
}
