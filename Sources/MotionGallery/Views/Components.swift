import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum Clipboard {
    static func copy(_ string: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = string
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        #endif
    }
}

/// A selectable capsule used for the component / trigger filters.
struct FilterChip: View {
    let title: String
    let symbol: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let symbol {
                    Image(systemName: symbol)
                }
                Text(title)
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .foregroundStyle(isSelected ? Color.white : Color.primary)
            .background(
                Capsule().fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
        .animation(.snappy, value: isSelected)
    }
}

/// Small rounded label for an effect's triggers.
struct TagLabel: View {
    let title: String
    let symbol: String

    var body: some View {
        Label(title, systemImage: symbol)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color.secondary.opacity(0.12)))
            .foregroundStyle(.secondary)
    }
}

/// Grid cell: live (non-interactive) preview + name + triggers.
struct EffectCard: View {
    let effect: MotionEffect

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            effect.demo()
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .clipped()
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.secondary.opacity(0.08))
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                // Taps go to the NavigationLink; play with the effect in the detail view.
                .allowsHitTesting(false)

            Text(effect.name)
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 4) {
                ForEach(effect.triggers) { trigger in
                    TagLabel(title: trigger.title, symbol: trigger.symbol)
                }
                if effect.requirement != .ios17 {
                    TagLabel(title: effect.requirement.title, symbol: "exclamationmark.circle")
                }
            }
        }
        .contentShape(Rectangle())
    }
}

/// Monospaced code block with a copy button.
struct CodeBlock: View {
    let title: String
    let code: String
    let copyLabel: String

    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Button {
                    Clipboard.copy(code)
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                } label: {
                    Label(copied ? "Copied" : copyLabel, systemImage: copied ? "checkmark" : "doc.on.doc")
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .sensoryFeedback(.success, trigger: copied) { _, new in new }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.footnote, design: .monospaced))
                    .textSelection(.enabled)
                    .padding(12)
            }
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.secondary.opacity(0.1))
            )
        }
    }
}
