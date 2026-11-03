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
