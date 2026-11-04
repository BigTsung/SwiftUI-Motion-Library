import SwiftUI

/// A segmented control whose selection indicator (a pill or an underline)
/// glides to the tapped option with `matchedGeometryEffect`.
public struct SlidingTabs<Value: Hashable>: View {
    /// How the selected option is marked.
    public enum Indicator: Sendable {
        /// A filled capsule behind the selected title.
        case pill
        /// A short bar under the selected title.
        case underline
    }

    @Binding private var selection: Value
    private let options: [Value]
    private let title: (Value) -> String
    private let indicator: Indicator
    private let color: Color

    @Namespace private var namespace
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - options: The options, in order.
    ///   - selection: The selected option.
    ///   - indicator: `.pill` or `.underline`.
    ///   - color: Colour of the indicator.
    ///   - title: The title of an option.
    public init(
        _ options: [Value],
        selection: Binding<Value>,
        indicator: Indicator = .pill,
        color: Color = .accentColor,
        title: @escaping (Value) -> String
    ) {
        self.options = options
        _selection = selection
        self.indicator = indicator
        self.color = color
        self.title = title
    }

    @available(*, deprecated, renamed: "init(_:selection:indicator:color:title:)")
    public init(
        _ options: [Value],
        selection: Binding<Value>,
        indicator: Indicator = .pill,
        tint: Color,
        title: @escaping (Value) -> String
    ) {
        self.init(options, selection: selection, indicator: indicator, color: tint, title: title)
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let selected = option == selection
                Button {
                    withAnimation(reduceMotion ? .easeInOut(duration: 0.15) : .spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = option
                    }
                } label: {
                    Text(title(option))
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundStyle(indicator == .pill && selected ? Color.white : selected ? color : Color.secondary)
                        .background { marker(selected) }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(4)
        .background {
            if indicator == .pill {
                Capsule().fill(Color.secondary.opacity(0.12))
            }
        }
    }

    @ViewBuilder
    private func marker(_ selected: Bool) -> some View {
        if selected {
            switch indicator {
            case .pill:
                Capsule()
                    .fill(color)
                    .matchedGeometryEffect(id: "indicator", in: namespace)
            case .underline:
                VStack {
                    Spacer()
                    Capsule()
                        .fill(color)
                        .frame(height: 3)
                        .padding(.horizontal, 10)
                }
                .matchedGeometryEffect(id: "indicator", in: namespace)
            }
        }
    }
}

public extension SlidingTabs where Value == String {
    /// Tabs whose options are their own titles.
    ///
    /// ```swift
    /// SlidingTabs(["Day", "Week", "Month"], selection: $range)
    /// ```
    init(_ options: [String], selection: Binding<String>, indicator: Indicator = .pill, color: Color = .accentColor) {
        self.init(options, selection: selection, indicator: indicator, color: color) { $0 }
    }

    @available(*, deprecated, renamed: "init(_:selection:indicator:color:)")
    init(_ options: [String], selection: Binding<String>, indicator: Indicator = .pill, tint: Color) {
        self.init(options, selection: selection, indicator: indicator, color: tint) { $0 }
    }
}

#Preview {
    struct Demo: View {
        @State private var range = "Week"
        var body: some View {
            VStack(spacing: 24) {
                SlidingTabs(["Day", "Week", "Month"], selection: $range)
                SlidingTabs(["Day", "Week", "Month"], selection: $range, indicator: .underline)
            }
        }
    }
    return Demo().padding()
}
