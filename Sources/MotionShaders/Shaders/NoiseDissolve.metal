// Stitchable shader for NoiseDissolve.swift (SwiftUI layer/distortion/colour effect).

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

/// Burns the view away in organic noise blotches. Pixels whose noise is
/// below `progress` vanish; a thin band just above it glows in `edge`.
[[ stitchable ]] half4 motionDissolve(float2 position, half4 color, float progress, float scale, half4 edge) {
    float n = motionNoise(position / scale) * 0.7 + motionNoise(position / (scale * 0.35)) * 0.3;
    // Stretch the range so 0 shows everything and 1 hides everything.
    float threshold = progress * 1.1 - 0.05;
    if (n < threshold) { return half4(0); }
    float glow = 1.0 - smoothstep(threshold, threshold + 0.06, n);
    if (progress <= 0.0) { glow = 0.0; }
    half4 burnt = mix(color, edge * color.a, half(glow));
    return burnt;
}
