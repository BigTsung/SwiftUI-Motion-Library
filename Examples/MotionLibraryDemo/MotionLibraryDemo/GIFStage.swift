import SwiftUI
import MotionGallery

/// Shows one gallery demo the way the README GIFs frame it: a 360 × 220 pt
/// light-grey stage. The rest of the screen is black so the recording script
/// can find the stage with ffmpeg's `cropdetect`.
struct GIFStage: View {
    let effectID: String

    var body: some View {
        ZStack {
            Color.black
            ZStack {
                Color(white: 0.97)
                if let effect = MotionCatalog.all.first(where: { $0.id == effectID }) {
                    effect.demo()
                } else {
                    Text("Unknown effect id: \(effectID)")
                }
            }
            .frame(width: 360, height: 220)
            .environment(\.colorScheme, .light)
            .tint(.blue)
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
    }
}
