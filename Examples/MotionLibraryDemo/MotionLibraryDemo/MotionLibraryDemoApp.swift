import SwiftUI
import MotionGallery

@main
struct MotionLibraryDemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// The gallery and the full-screen scroll examples, in two tabs.
///
/// Launch environment hooks (used by the UI tests and
/// `Scripts/record-simulator-gifs.sh`):
/// - `SCROLL_EXAMPLE=<id>` opens one scroll example full screen.
/// - `GIF_EFFECT=<catalog id>` shows that gallery demo on the README GIF stage.
struct RootView: View {
    private let environment = ProcessInfo.processInfo.environment

    var body: some View {
        if let id = environment["GIF_EFFECT"] {
            GIFStage(effectID: id)
        } else if let id = environment["SCROLL_EXAMPLE"], let example = ScrollExample(rawValue: id) {
            example.screen
        } else {
            TabView {
                MotionGalleryView()
                    .tabItem { Label("Gallery", systemImage: "square.grid.2x2") }
                ScrollExamplesView()
                    .tabItem { Label("Scroll", systemImage: "scroll") }
            }
        }
    }
}
