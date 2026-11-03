// Stitchable shader for HeatHaze.swift (SwiftUI layer/distortion/colour effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// A cheap, stable hash of a 2D point into 0...1.
static float motionHash(float2 p) {
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

/// Smooth value noise in 0...1.
static float motionNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float a = motionHash(i);
    float b = motionHash(i + float2(1, 0));
    float c = motionHash(i + float2(0, 1));
    float d = motionHash(i + float2(1, 1));
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

/// Wobbles pixels sideways with layered noise rising over time, like air
/// shimmering over hot asphalt. Stronger towards the bottom.
[[ stitchable ]] float2 motionHeatHaze(float2 position, float2 size, float time, float strength) {
    float rise = position.y * 0.05 + time * 2.0;
    float n = motionNoise(float2(position.x * 0.04, rise)) - 0.5;
    float m = motionNoise(float2(position.x * 0.09 + 10.0, rise * 1.7)) - 0.5;
    float weight = 0.35 + 0.65 * (position.y / max(size.y, 1.0));
    return position + float2((n + 0.5 * m) * strength * weight, n * strength * 0.3 * weight);
}
