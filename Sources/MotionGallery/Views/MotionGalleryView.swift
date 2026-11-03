import SwiftUI

/// A browsable, filterable gallery of every effect in MotionLibrary.
///
/// Drop it into any app (or an Xcode preview) to explore the library:
///
/// ```swift
/// import MotionGallery
///
/// @main
/// struct DemoApp: App {
///     var body: some Scene {
///         WindowGroup { MotionGalleryView() }
///     }
/// }
/// ```
public struct MotionGalleryView: View {
    @State private var component: MotionComponent?
    @State private var trigger: MotionTrigger?
    @State private var search = ""

    public init() {}

    private var effects: [MotionEffect] {
        MotionCatalog.filtered(component: component, trigger: trigger, search: search)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    filters
                    grid
                }
                .padding(.vertical)
            }
            .navigationTitle("Motion Library")
            .searchable(text: $search, prompt: "Search effects")
            .navigationDestination(for: String.self) { id in
                if let effect = MotionCatalog.all.first(where: { $0.id == id }) {
                    MotionDetailView(effect: effect)
                }
            }
        }
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 10) {
            chipRow(label: "Component") {
                FilterChip(title: "All", symbol: nil, isSelected: component == nil) { component = nil }
                ForEach(MotionComponent.allCases) { item in
                    FilterChip(title: item.title, symbol: item.symbol, isSelected: component == item) {
                        component = component == item ? nil : item
                    }
                }
            }
            chipRow(label: "Trigger") {
                FilterChip(title: "All", symbol: nil, isSelected: trigger == nil) { trigger = nil }
                ForEach(MotionTrigger.allCases) { item in
                    FilterChip(title: item.title, symbol: item.symbol, isSelected: trigger == item) {
                        trigger = trigger == item ? nil : item
                    }
                }
            }
            Text("\(effects.count) of \(MotionCatalog.all.count) effects")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }

    private func chipRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) { content() }
                    .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private var grid: some View {
        if effects.isEmpty {
            ContentUnavailableView(
                "No matching effects",
                systemImage: "sparkle.magnifyingglass",
                description: Text("Try another component × trigger combination.")
            )
            .padding(.top, 40)
        } else {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 20) {
                ForEach(effects) { effect in
                    NavigationLink(value: effect.id) {
                        EffectCard(effect: effect)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    MotionGalleryView()
}
