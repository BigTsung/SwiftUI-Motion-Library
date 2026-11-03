// Stitchable shader for ChromaticAberration.swift (SwiftUI layer/distortion/colour effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Splits red and blue apart horizontally by `amount` points, like a cheap lens.
[[ stitchable ]] half4 motionChromatic(float2 position, SwiftUI::Layer layer, float amount) {
    half4 base = layer.sample(position);
    half4 red = layer.sample(position + float2(amount, 0));
    half4 blue = layer.sample(position - float2(amount, 0));
    half alpha = max(base.a, max(red.a, blue.a));
    return half4(red.r, base.g, blue.b, alpha);
}
