// Stitchable shader for Genie.swift (SwiftUI distortion effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// The macOS-style "genie" minimise: the bottom of the view pinches towards
/// `target` (0...1 along the bottom edge) while the rest bends after it,
/// then the whole shape slides down and into that point.
[[ stitchable ]] float2 motionGenie(float2 position, float2 size, float progress, float target) {
    float pinch = clamp(progress * 2.0, 0.0, 1.0);
    float slide = clamp(progress * 2.0 - 1.0, 0.0, 1.0);
    // Anything that has slid past the bottom edge has gone into the target.
    if (position.y > size.y) { return float2(-1e5); }
    // Slide: content moves down by up to the full height.
    float y = position.y - slide * size.y;
    if (y < 0.0) { return float2(-1e5); }
    float v = clamp(y / size.y, 0.0, 1.0);
    // The pinch grows towards the bottom with an S-curve, and reaches higher
    // up as the slide progresses.
    float bend = smoothstep(0.0, 1.0, clamp(v + slide, 0.0, 1.0));
    float squeeze = pinch * bend;
    float targetX = target * size.x;
    float narrow = 6.0;
    float left = mix(0.0, targetX - narrow * 0.5, squeeze);
    float right = mix(size.x, targetX + narrow * 0.5, squeeze);
    if (position.x < left || position.x > right) { return float2(-1e5); }
    float x = (position.x - left) / max(right - left, 0.001) * size.x;
    return float2(x, y);
}
