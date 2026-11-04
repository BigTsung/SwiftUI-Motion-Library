// Stitchable shader for FlagWave.swift (SwiftUI layer effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Waves the layer like a flag on a pole at its leading edge: ripples run
/// along it, growing away from the pole, and the folds catch light and
/// shadow.
[[ stitchable ]] half4 motionFlagWave(float2 position, SwiftUI::Layer layer, float2 size, float time, float amplitude, float wavelength) {
    float reach = clamp(position.x / max(size.x, 1.0), 0.0, 1.0);
    float phase = position.x / wavelength * 2.0 * M_PI_F - time * 4.0;
    float wave = sin(phase) + 0.35 * sin(phase * 2.3 + 1.1);
    float dy = amplitude * reach * wave;
    float dx = amplitude * 0.25 * reach * cos(phase);
    half4 colour = layer.sample(float2(position.x + dx, position.y - dy));
    // Light on the slopes facing up, shade on the ones facing down.
    float slope = cos(phase) + 0.8 * cos(phase * 2.3 + 1.1);
    half shade = half(1.0 + 0.18 * reach * slope);
    return half4(clamp(colour.rgb * shade, 0.0h, colour.a), colour.a);
}
