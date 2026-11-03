import SwiftUI

/// Small dots that fly outward from the centre of the view, e.g. on a "like"
/// tap. Plays every time `trigger` changes.
struct BurstModifier<Trigger: Equatable>: ViewModifier {
    var trigger: Trigger
    var color: Color
    var count: Int
    var radius: CGFloat
    var isEnabled: Bool

    @State private var bursts: [UUID] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    ForEach(bursts, id: \.self) { _ in
                        BurstParticles(color: color, count: count, radius: radius)
                    }
                }
                .allowsHitTesting(false)
            }
            .onChange(of: trigger) {
                // Reduce Motion: skip the particles.
                guard isEnabled, !reduceMotion else { return }
                let id = UUID()
                bursts.append(id)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    bursts.removeAll { $0 == id }
                }
            }
    }
}

private struct BurstParticles: View {
    let color: Color
    let count: Int
    let radius: CGFloat

    @State private var exploded = false

    var body: some View {
        ZStack {
            ForEach(0..<max(1, count), id: \.self) { index in
                particle(angle: Double(index) / Double(max(1, count)) * 2 * .pi, index: index)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                exploded = true
            }
        }
    }

    private func particle(angle: Double, index: Int) -> some View {
        // Alternate particle size and distance so the burst feels organic.
        let size: CGFloat = index.isMultiple(of: 2) ? 7 : 4
        let distance = radius * (index.isMultiple(of: 3) ? 0.75 : 1)
        return Circle()
            .fill(color)
            .frame(width: size, height: size)
            // Scale before offsetting, otherwise the scale also shrinks the
            // travel distance and the particles never leave the icon.
            .scaleEffect(exploded ? 0.3 : 1)
            .offset(
                x: exploded ? CGFloat(cos(angle)) * distance : 0,
                y: exploded ? CGFloat(sin(angle)) * distance : 0
            )
            .opacity(exploded ? 0 : 1)
    }
}

public extension View {
    /// Emits a burst of particles every time `trigger` changes.
    ///
    /// ```swift
    /// Image(systemName: isLiked ? "heart.fill" : "heart")
    ///     .burst(trigger: isLiked, color: .pink, isEnabled: isLiked)
    /// ```
    func burst<Trigger: Equatable>(
        trigger: Trigger,
        color: Color = .pink,
        count: Int = 12,
        radius: CGFloat = 36,
        isEnabled: Bool = true
    ) -> some View {
        modifier(BurstModifier(trigger: trigger, color: color, count: count, radius: radius, isEnabled: isEnabled))
    }
}

#Preview {
    struct Demo: View {
        @State private var liked = false
        var body: some View {
            Button {
                liked.toggle()
            } label: {
                Image(systemName: liked ? "heart.fill" : "heart")
                    .font(.system(size: 44))
                    .foregroundStyle(liked ? Color.pink : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .burst(trigger: liked, isEnabled: liked)
        }
    }
    return Demo()
}
