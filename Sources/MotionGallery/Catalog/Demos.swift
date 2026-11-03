import SwiftUI
import MotionLibrary

// Small self-contained demo views used by the catalog. Each demo should look
// good in a ~160x140 grid cell AND in the large detail preview.

struct TypewriterDemo: View {
    var body: some View {
        TypewriterText("Hello, SwiftUI motion.")
            .font(.title3.weight(.semibold))
            .multilineTextAlignment(.center)
            .padding()
    }
}

struct ScrambleDemo: View {
    var body: some View {
        ScrambleText("ACCESS GRANTED", duration: 1.2)
            .font(.title3.bold())
            .foregroundStyle(.green)
    }
}

struct ShimmerDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle().frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4).frame(width: 90, height: 10)
                    RoundedRectangle(cornerRadius: 4).frame(width: 60, height: 10)
                }
            }
            RoundedRectangle(cornerRadius: 6).frame(height: 40)
        }
        .foregroundStyle(.gray.opacity(0.3))
        .frame(width: 150)
        .shimmer()
    }
}

struct PressableDemo: View {
    var body: some View {
        Button {
        } label: {
            Text("Press me")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.accentColor))
        }
        .buttonStyle(.pressable)
    }
}

struct RippleDemo: View {
    var body: some View {
        Text("Tap anywhere")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(width: 150, height: 64)
            .background(Color.indigo, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .ripple(cornerRadius: 14)
    }
}

struct ShakeDemo: View {
    @State private var attempts = 0

    var body: some View {
        Button("Wrong password") { attempts += 1 }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .shake(trigger: attempts)
            .sensoryFeedback(.error, trigger: attempts)
    }
}

struct StaggeredDemo: View {
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.25 + Double(index) * 0.2))
                    .frame(width: 140, height: 18)
                    .staggeredAppear(index: index, delayPerItem: 0.12)
            }
        }
    }
}

struct TiltDemo: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: 100, height: 120)
            .overlay(Image(systemName: "hand.draw").font(.title).foregroundStyle(.white))
            .tiltOnDrag(maxAngle: 18, cornerRadius: 16)
    }
}

struct ScrollRevealDemo: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(0..<20, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor.gradient)
                        .frame(height: 44)
                        .overlay(Text("Row \(index + 1)").font(.caption.bold()).foregroundStyle(.white))
                        .scrollReveal()
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(maxHeight: 280)
    }
}

struct PulseDemo: View {
    var body: some View {
        ZStack {
            PulseRings(color: .green)
                .frame(width: 110, height: 110)
            Circle()
                .fill(.green)
                .frame(width: 22, height: 22)
        }
    }
}

struct BurstDemo: View {
    @State private var liked = false

    var body: some View {
        Button {
            liked.toggle()
        } label: {
            Image(systemName: liked ? "heart.fill" : "heart")
                .font(.system(size: 40))
                .foregroundStyle(liked ? Color.pink : Color.secondary)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .burst(trigger: liked, isEnabled: liked)
    }
}

struct AuroraDemo: View {
    var body: some View {
        AuroraBackground()
            .overlay(Text("Welcome").font(.title2.bold()).foregroundStyle(.white))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct RollingNumberDemo: View {
    @State private var value = 1280

    var body: some View {
        VStack(spacing: 10) {
            RollingNumber(value: value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
            HStack {
                Button("−") { value -= Int.random(in: 1...300) }
                Button("+") { value += Int.random(in: 1...300) }
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Button (v0.2)

struct MagneticDemo: View {
    var body: some View {
        Button("Hover me") { }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .magnetic(strength: 0.35, radius: 50)
    }
}

struct HoldToConfirmDemo: View {
    var body: some View {
        HoldToConfirmButton("Hold to delete") { }
    }
}

struct StatusButtonDemo: View {
    @State private var status = MotionButtonStatus.idle
    @State private var attempts = 0

    var body: some View {
        StatusButton("Pay now", status: status) {
            attempts += 1
            status = .loading
            // Alternate success and failure so both endings are visible.
            let succeeds = attempts % 2 == 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                status = succeeds ? .success : .failure
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                status = .idle
            }
        }
    }
}

struct GlowBorderDemo: View {
    var body: some View {
        Text("Upgrade to Pro")
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 14)
            .background(Color.black, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .glowBorder()
    }
}

// MARK: - Text (v0.2)

struct GradientSweepDemo: View {
    var body: some View {
        Text("Motion")
            .font(.system(size: 40, weight: .heavy, design: .rounded))
            .gradientSweep()
    }
}

struct BlurInDemo: View {
    var body: some View {
        BlurInText("Design is how it works.")
            .font(.title3.weight(.semibold))
            .padding(.horizontal)
    }
}

struct MarqueeDemo: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "music.note")
                .foregroundStyle(.pink)
            MarqueeText("Now playing: Midnight Drive — Neon Coast · Summer Sessions")
                .font(.headline)
        }
        .frame(width: 180)
    }
}

struct WaveTextDemo: View {
    var body: some View {
        if #available(iOS 18, macOS 15, visionOS 2, *) {
            WaveText("Making waves")
                .font(.title2.bold())
                .foregroundStyle(.blue)
        } else {
            Text("Requires iOS 18")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Card & Group (v0.2)

struct FlipCardDemo: View {
    @State private var flipped = false

    var body: some View {
        FlipCard(isFlipped: flipped) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.blue.gradient)
                .overlay(Image(systemName: "questionmark").font(.largeTitle.bold()).foregroundStyle(.white))
        } back: {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.orange.gradient)
                .overlay(Text("42").font(.largeTitle.bold()).foregroundStyle(.white))
        }
        .frame(width: 90, height: 120)
        .onTapGesture { flipped.toggle() }
    }
}

struct SwipeStackDemo: View {
    private struct Card: Identifiable {
        let id: Int
        let color: Color
        let symbol: String
    }

    private let cards = [
        Card(id: 0, color: .pink, symbol: "heart.fill"),
        Card(id: 1, color: .orange, symbol: "sun.max.fill"),
        Card(id: 2, color: .teal, symbol: "leaf.fill"),
        Card(id: 3, color: .indigo, symbol: "moon.stars.fill"),
    ]

    var body: some View {
        SwipeCardStack(cards) { card in
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(card.color.gradient)
                .frame(width: 96, height: 120)
                .overlay(Image(systemName: card.symbol).font(.largeTitle).foregroundStyle(.white))
        }
        .offset(y: -8)
    }
}

struct DemoSwatch: Identifiable {
    let id: Int
    let colors: [Color]
    let symbol: String

    static let all = [
        DemoSwatch(id: 0, colors: [.orange, .pink], symbol: "sun.horizon.fill"),
        DemoSwatch(id: 1, colors: [.teal, .blue], symbol: "water.waves"),
        DemoSwatch(id: 2, colors: [.purple, .indigo], symbol: "moon.stars.fill"),
        DemoSwatch(id: 3, colors: [.mint, .green], symbol: "leaf.fill"),
        DemoSwatch(id: 4, colors: [.yellow, .orange], symbol: "bolt.fill"),
        DemoSwatch(id: 5, colors: [.pink, .purple], symbol: "sparkles"),
    ]

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct ParallaxDemo: View {
    var selection: Binding<Int?>?

    var body: some View {
        ParallaxCarousel(DemoSwatch.all, selection: selection, cornerRadius: 16) { swatch in
            swatch.gradient
                .overlay(Image(systemName: swatch.symbol).font(.system(size: 40)).foregroundStyle(.white.opacity(0.9)))
        }
        .frame(height: 120)
    }
}

struct ExpandableCardDemo: View {
    @State private var expanded = false

    var body: some View {
        ExpandableCard(isExpanded: $expanded, cornerRadius: 12) {
            Label("Shipping", systemImage: "shippingbox").font(.subheadline.weight(.semibold))
        } detail: {
            Text("Arrives Thursday. Free returns within 30 days.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 200)
    }
}

// MARK: - Shape & Loader (v0.2)

struct CheckmarkDemo: View {
    @State private var checked = false

    var body: some View {
        AnimatedCheckmark(isChecked: checked)
            .frame(width: 64, height: 64)
            .contentShape(Rectangle())
            .onTapGesture { checked.toggle() }
            .task {
                try? await Task.sleep(for: .seconds(0.4))
                checked = true
            }
    }
}

struct ConfettiDemo: View {
    @State private var celebrations = 0

    var body: some View {
        Button("Celebrate") { celebrations += 1 }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .confetti(trigger: celebrations, spread: 120)
    }
}

struct LoaderDemo: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach(MotionLoader.Style.allCases, id: \.self) { style in
                MotionLoader(style)
                    .frame(width: 24, height: 24)
            }
        }
    }
}

struct BlobDemo: View {
    var body: some View {
        MorphingBlob()
            .frame(width: 100, height: 100)
    }
}

// MARK: - Particle & 3D (v0.2)

struct ParticleFieldDemo: View {
    var body: some View {
        ParticleField(count: 40)
            .background(Color(red: 0.05, green: 0.07, blue: 0.16))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct StarfieldDemo: View {
    var body: some View {
        Starfield()
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct CoverFlowDemo: View {
    var selection: Binding<Int?>?

    var body: some View {
        CoverFlow(DemoSwatch.all, selection: selection, itemWidth: 84) { swatch in
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(swatch.gradient)
                .frame(height: 84)
                .overlay(Image(systemName: swatch.symbol).font(.title).foregroundStyle(.white))
        }
        .frame(height: 120)
    }
}

struct Float3DDemo: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
            .frame(width: 72, height: 72)
            .overlay(Image(systemName: "cube.fill").font(.system(size: 32)).foregroundStyle(.white))
            .float3D(height: 8)
    }
}
