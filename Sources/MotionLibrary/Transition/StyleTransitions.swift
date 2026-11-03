import SwiftUI

// Transitions that change how the view itself looks (scale, blur, skew,
// exposure) on its way in and out.

// MARK: - Poof

/// The view puffs away like smoke: it swells and blurs out on removal, and
/// condenses from a blur on insertion.
public struct PoofTransition: Transition {
    public init() {}

    public func body(content: Content, phase: TransitionPhase) -> some View {
        PoofBody(content: content, phase: phase)
    }
}

private struct PoofBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // Reduce Motion: blur and fade only, no scaling.
        let scale: CGFloat = reduceMotion ? 1 : phase == .didDisappear ? 1.35 : phase == .willAppear ? 0.7 : 1
        content
            .scaleEffect(scale)
            .blur(radius: phase.isIdentity ? 0 : 14)
            .opacity(phase.isIdentity ? 1 : 0)
    }
}

public extension Transition where Self == PoofTransition {
    /// Puffs the view away like smoke (and condenses it back in).
    ///
    /// ```swift
    /// ForEach(notes) { note in
    ///     NoteRow(note).transition(.poof)
    /// }
    /// ```
    static var poof: PoofTransition { PoofTransition() }
}

// MARK: - Swoosh

/// The view whooshes in from the leading edge leaning forward, and out to
/// the trailing edge, with a motion blur.
public struct SwooshTransition: Transition {
    public init() {}

    public func body(content: Content, phase: TransitionPhase) -> some View {
        SwooshBody(content: content, phase: phase)
    }
}

private struct SwooshBody<Content: View>: View {
    let content: Content
    let phase: TransitionPhase

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        // TransitionPhase.value is -1 before insertion, 0 at rest and 1 after removal.
        let value = CGFloat(phase.value)
        content
            // Reduce Motion: fade only.
            .modifier(SkewSlide(progress: reduceMotion ? 0 : value))
            .blur(radius: abs(value) * 6)
            .opacity(1 - abs(Double(value)))
    }
}

/// Slides the view by `progress` × its width while skewing it in the
/// direction of travel.
struct SkewSlide: GeometryEffect {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let skew = -progress * 0.6
        // Skew around the vertical centre so the view doesn't drift sideways.
        let transform = CGAffineTransform(a: 1, b: 0, c: skew, d: 1, tx: progress * size.width - skew * size.height / 2, ty: 0)
        return ProjectionTransform(transform)
    }
}

public extension Transition where Self == SwooshTransition {
    /// Whooshes the view in from the leading edge and out to the trailing edge.
    ///
    /// ```swift
    /// Toast().transition(.swoosh)
    /// ```
    static var swoosh: SwooshTransition { SwooshTransition() }
}

// MARK: - Film exposure

/// The view develops like a photo: it starts blown out to white and
/// colourless, then the exposure and colour settle in.
public struct FilmExposureTransition: Transition {
    public init() {}

    public func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .brightness(phase.isIdentity ? 0 : 0.9)
            .saturation(phase.isIdentity ? 1 : 0)
            .opacity(phase.isIdentity ? 1 : 0)
    }
}

public extension Transition where Self == FilmExposureTransition {
    /// Develops the view from an over-exposed white, like a photo.
    ///
    /// ```swift
    /// AsyncImage(url: url) { image in
    ///     image.resizable().transition(.filmExposure)
    /// } placeholder: { ProgressView() }
    /// ```
    static var filmExposure: FilmExposureTransition { FilmExposureTransition() }
}

#Preview {
    struct Demo: View {
        @State private var shown = true
        var body: some View {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        ZStack {
                            if shown {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.gradient)
                                    .transition(index == 0 ? AnyTransition(.poof) : index == 1 ? AnyTransition(.swoosh) : AnyTransition(.filmExposure))
                            }
                        }
                        .frame(width: 70, height: 70)
                    }
                }
                Button("Toggle") { withAnimation(.easeInOut(duration: 0.6)) { shown.toggle() } }
            }
        }
    }
    return Demo().padding()
}
