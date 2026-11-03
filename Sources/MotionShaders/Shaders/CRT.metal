// Stitchable shader for CRT.swift (SwiftUI layer/distortion/colour effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// An old CRT screen: barrel-curved glass, scanlines, a rolling bright band,
/// slight colour fringing, a dark vignette and a faint flicker.
[[ stitchable ]] half4 motionCRT(float2 position, SwiftUI::Layer layer, float2 size, float time, float curvature) {
    float2 uv = position / size;
    float2 centred = uv * 2.0 - 1.0;
    // Barrel distortion: push points outward by their squared distance.
    centred *= 1.0 + curvature * dot(centred, centred);
    uv = (centred + 1.0) * 0.5;
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) { return half4(0, 0, 0, 1); }
    float2 p = uv * size;
    half4 color;
    color.r = layer.sample(p + float2(0.8, 0)).r;
    color.g = layer.sample(p).g;
    color.b = layer.sample(p - float2(0.8, 0)).b;
    color.a = 1.0;
    float scanline = 0.8 + 0.2 * sin(p.y * 3.14159 * 0.66);
    float band = 1.0 + 0.08 * smoothstep(0.92, 1.0, sin(uv.y * 3.0 - time * 1.5));
    float vignette = smoothstep(1.25, 0.4, length(centred));
    float flicker = 0.97 + 0.03 * sin(time * 60.0);
    color.rgb *= half(scanline * band * vignette * flicker);
    return color;
}
