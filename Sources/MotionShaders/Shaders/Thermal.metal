// Stitchable shader for Thermal.swift (SwiftUI colour effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Maps brightness to a heat-camera palette, from cold black and indigo
/// through magenta and red to hot yellow and white. `intensity` blends from
/// the original colours (0) to the full false colour (1).
[[ stitchable ]] half4 motionThermal(float2 position, half4 colour, float intensity) {
    if (colour.a <= 0.0h) { return colour; }
    float3 rgb = float3(colour.rgb / colour.a);
    float heat = dot(rgb, float3(0.299, 0.587, 0.114));
    const float3 stops[7] = {
        float3(0.0, 0.0, 0.05), float3(0.2, 0.05, 0.45), float3(0.65, 0.05, 0.6),
        float3(0.95, 0.15, 0.2), float3(1.0, 0.5, 0.0), float3(1.0, 0.9, 0.2), float3(1.0, 1.0, 1.0)
    };
    float scaled = clamp(heat, 0.0, 1.0) * 6.0;
    int i = min(int(floor(scaled)), 5);
    float3 thermal = mix(stops[i], stops[i + 1], scaled - float(i));
    float3 result = mix(rgb, thermal, clamp(intensity, 0.0, 1.0));
    return half4(half3(result) * colour.a, colour.a);
}
