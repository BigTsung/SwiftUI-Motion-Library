// Shared by the particle and background effects that need stable random
// layouts. Copy this file along with any effect that uses `SplitMix64`.

import SwiftUI

/// Small deterministic random generator, so particle layouts are stable
/// between launches and previews.
struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    /// A Double in 0..<1.
    mutating func unit() -> Double { Double.random(in: 0..<1, using: &self) }
}

extension CGFloat {
    /// Wraps the value into 0..<length.
    func wrapped(to length: CGFloat) -> CGFloat {
        let r = truncatingRemainder(dividingBy: length)
        return r < 0 ? r + length : r
    }
}
