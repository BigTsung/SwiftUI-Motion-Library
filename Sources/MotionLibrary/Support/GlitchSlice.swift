// Shared by GlitchTransition and OrigamiFold.

import SwiftUI

/// One horizontal band of the view.
struct GlitchSlice: Shape {
    var index: Int
    var count: Int

    func path(in rect: CGRect) -> Path {
        let height = rect.height / CGFloat(count)
        return Path(CGRect(x: rect.minX - rect.width, y: rect.minY + CGFloat(index) * height, width: rect.width * 3, height: height + 0.5))
    }
}
