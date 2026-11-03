import SwiftUI
import MotionLibrary

/// Full-screen versions of the scroll-driven effects. The gallery cells are
/// small and scroll themselves; these are for scrolling with a finger.
enum ScrollExample: String, CaseIterable, Identifiable {
    case stackingCards = "stacking-cards"
    case shrinkingHeader = "shrinking-header"
    case stretchyHeader = "stretchy-header"
    case readingProgress = "reading-progress"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stackingCards: "Stacking Cards"
        case .shrinkingHeader: "Shrinking Header"
        case .stretchyHeader: "Stretchy Header"
        case .readingProgress: "Reading Progress"
        }
    }

    var api: String {
        switch self {
        case .stackingCards: ".stackingCard()"
        case .shrinkingHeader: ".shrinkingHeader()"
        case .stretchyHeader: ".stretchyHeader()"
        case .readingProgress: "ReadingProgressScrollView { … }"
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .stackingCards: StackingCardsScreen()
        case .shrinkingHeader: ShrinkingHeaderScreen()
        case .stretchyHeader: StretchyHeaderScreen()
        case .readingProgress: ReadingProgressScreen()
        }
    }
}

struct ScrollExamplesView: View {
    var body: some View {
        NavigationStack {
            List(ScrollExample.allCases) { example in
                NavigationLink {
                    example.screen
                        .navigationTitle(example.title)
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(example.title)
                        Text(example.api).font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Scroll Effects")
        }
    }
}

private let palette: [Color] = [.pink, .orange, .teal, .indigo, .mint, .purple, .blue, .red]

private struct ExampleRow: View {
    let index: Int

    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(palette[index % palette.count].gradient).frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text("Message \(index + 1)").font(.headline)
                Text("A placeholder row to scroll past.").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 64)
        .background(Color(.systemBackground))
    }
}

struct StackingCardsScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(palette[index].gradient)
                        .frame(height: 200)
                        .overlay(Text("Card \(index + 1)").font(.largeTitle.bold()).foregroundStyle(.white))
                        .stackingCard()
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("card-\(index)")
                }
            }
            .padding()
            // Room for the last card to scroll up and cover the pile.
            .padding(.bottom, 400)
        }
    }
}

struct ShrinkingHeaderScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                    .frame(height: 160)
                    .overlay(Text("Inbox").font(.largeTitle.bold()).foregroundStyle(.white))
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("header")
                    .shrinkingHeader()
                ForEach(0..<30, id: \.self) { ExampleRow(index: $0) }
            }
        }
    }
}

struct StretchyHeaderScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LinearGradient(colors: [.orange, .pink], startPoint: .top, endPoint: .bottom)
                    .frame(height: 260)
                    .overlay(Image(systemName: "mountain.2.fill").font(.system(size: 60)).foregroundStyle(.white))
                    .accessibilityElement()
                    .accessibilityIdentifier("header")
                    .stretchyHeader()
                ForEach(0..<30, id: \.self) { ExampleRow(index: $0) }
            }
        }
    }
}

struct ReadingProgressScreen: View {
    var body: some View {
        ReadingProgressScrollView(color: .pink, height: 6) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Pull to read").font(.largeTitle.bold())
                ForEach(0..<40, id: \.self) { index in
                    Text("Paragraph \(index + 1). Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                }
            }
            .padding()
        }
    }
}
