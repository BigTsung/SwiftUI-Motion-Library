import SwiftUI

/// The haptics the package plays. `SensoryFeedback` and `sensoryFeedback`
/// need visionOS 26, but the package supports visionOS 1, so call sites use
/// this enum and `.haptic(…)`, which does nothing on visionOS (it has no
/// haptics anyway).
enum Haptic: Equatable {
    case success
    case error
    case lightImpact

    #if !os(visionOS)
    var feedback: SensoryFeedback {
        switch self {
        case .success: .success
        case .error: .error
        case .lightImpact: .impact(weight: .light)
        }
    }
    #endif
}

extension View {
    /// Plays `haptic` every time `trigger` changes.
    func haptic<T: Equatable>(_ haptic: Haptic, trigger: T) -> some View {
        #if os(visionOS)
        self
        #else
        sensoryFeedback(haptic.feedback, trigger: trigger)
        #endif
    }

    /// Plays `haptic` when `trigger` changes and `condition` returns true.
    func haptic<T: Equatable>(_ haptic: Haptic, trigger: T, condition: @escaping (T, T) -> Bool) -> some View {
        #if os(visionOS)
        self
        #else
        sensoryFeedback(haptic.feedback, trigger: trigger, condition: condition)
        #endif
    }

    /// Plays the haptic returned by `haptic` (if any) when `trigger` changes.
    func haptic<T: Equatable>(trigger: T, _ haptic: @escaping (T, T) -> Haptic?) -> some View {
        #if os(visionOS)
        self
        #else
        sensoryFeedback(trigger: trigger) { old, new in haptic(old, new)?.feedback }
        #endif
    }
}
