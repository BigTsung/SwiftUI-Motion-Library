import SwiftUI

/// Short spark lines shoot out from the exact point the user tapped.
struct ClickSparkModifier: ViewModifier {
    var color: Color
    var count: Int
    var radius: CGFloat

    @State private var sparks: [Spark] = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Spark: Identifiable {
        let id = UUID()
        let location: CGPoint
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    ForEach(sparks) { spark in
                        SparkLines(color: color, count: count, radius: radius)
                            .position(spark.location)
                    }
                }
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .simultaneousGesture(
                SpatialTapGesture().onEnded { value in
                    // Reduce Motion: no sparks.
                    guard !reduceMotion else { return }
                    let spark = Spark(location: value.location)
                    sparks.append(spark)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        sparks.removeAll { $0.id == spark.id }
                    }
                }
            )
    }
}

private struct SparkLines: View {
    let color: Color
    let count: Int
    let radius: CGFloat

    @State private var fired = false

    var body: some View {
        ZStack {
            ForEach(0..<max(1, count), id: \.self) { index in
                Capsule()
                    .fill(color)
                    .frame(width: 2.5, height: radius * 0.45)
                    // Shrinks toward its outer end as it flies.
                    .scaleEffect(y: fired ? 0.1 : 1, anchor: .top)
                    .offset(y: -(fired ? radius : radius * 0.3))
                    .rotationEffect(.degrees(Double(index) / Double(max(1, count)) * 360))
            }
        }
        .opacity(fired ? 0 : 1)
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) { fired = true }
        }
    }
}

public extension View {
    /// Shoots spark lines out of every tap point.
    ///
    /// ```swift
    /// Button("Launch") { }
    ///     .buttonStyle(.borderedProminent)
    ///     .clickSpark(color: .orange)
    /// ```
    func clickSpark(color: Color = .orange, count: Int = 8, radius: CGFloat = 28) -> some View {
        modifier(ClickSparkModifier(color: color, count: count, radius: radius))
    }
}

#Preview {
    RoundedRectangle(cornerRadius: 16)
        .fill(.black)
        .frame(width: 260, height: 160)
        .overlay(Text("Click anywhere").foregroundStyle(.white))
        .clickSpark()
}
