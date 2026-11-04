// Stitchable shader for Disintegrate.swift (SwiftUI layer effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// A cheap, stable hash of a 2D point into 0...1.
static float motionHash(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

/// Crumbles the layer into grains of sand that blow away on the wind,
/// sweeping from the leading edge to the trailing one as `progress` goes
/// from 0 to 1.
[[ stitchable ]] half4 motionDisintegrate(float2 position, SwiftUI::Layer layer, float2 size, float progress, float grain, float2 wind) {
    float2 cell = floor(position / grain);
    float n = motionHash(cell);
    float n2 = motionHash(cell + 17.0);
    // Grains leave in a sweep along the wind, with some randomness.
    float2 direction = normalize(wind);
    float along = dot(position / max(size, float2(1.0)), direction) * 0.5 + 0.5;
    float delay = (1.0 - along) * 0.55 + n * 0.3;
    float local = clamp((progress * 1.4 - delay) / 0.5, 0.0, 1.0);
    if (local <= 0.0) { return layer.sample(position); }
    // A grain that has left: some vanish, the rest are drawn from upwind.
    if (n2 < local * 1.15) { return half4(0); }
    float2 drift = wind * local * local + float2(sin(n * 40.0), cos(n * 31.0)) * local * grain * 6.0;
    half4 colour = layer.sample(position - drift);
    return colour * half(1.0 - local);
}
