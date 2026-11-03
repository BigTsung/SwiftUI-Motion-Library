import SwiftUI

/// Large interactive preview of one effect, with its usage code and AI prompt.
public struct MotionDetailView: View {
    let effect: MotionEffect

    /// Changing this re-creates the demo so appear/loop effects replay.
    @State private var replayToken = 0

    public init(effect: MotionEffect) {
        self.effect = effect
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                preview

                VStack(alignment: .leading, spacing: 8) {
                    Text(effect.summary)
                        .font(.body)
                    HStack(spacing: 6) {
                        TagLabel(title: effect.component.title, symbol: effect.component.symbol)
                        ForEach(effect.triggers) { trigger in
                            TagLabel(title: trigger.title, symbol: trigger.symbol)
                        }
                    }
                    Text("Requires \(effect.requirement.platforms)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Source: \(effect.sourcePath)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                CodeBlock(title: "Usage", code: effect.usage, copyLabel: "Copy code")
                CodeBlock(title: "AI prompt", code: effect.prompt, copyLabel: "Copy prompt")
            }
            .padding()
        }
        .navigationTitle(effect.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    @MainActor
    private var preview: some View {
        effect.demo()
            .id(replayToken)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 280)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.secondary.opacity(0.08))
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(alignment: .topTrailing) {
                Button {
                    replayToken += 1
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.subheadline.weight(.semibold))
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .buttonStyle(.plain)
                .padding(10)
                .accessibilityLabel("Replay")
            }
    }
}

#Preview {
    NavigationStack {
        MotionDetailView(effect: MotionCatalog.all[0])
    }
}
