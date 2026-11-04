// Stitchable shader for Halftone.swift (SwiftUI layer effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Redraws the layer as a grid of round dots on paper, like newsprint: the
/// grid is rotated by `angle`, each dot takes the colour under its centre,
/// and darker areas get bigger dots.
[[ stitchable ]] half4 motionHalftone(float2 position, SwiftUI::Layer layer, float dotSize, float angle, half4 paper) {
    float c = cos(angle), s = sin(angle);
    // Into the rotated grid and back out again.
    float2 p = float2(c * position.x + s * position.y, -s * position.x + c * position.y);
    float2 cell = (floor(p / dotSize) + 0.5) * dotSize;
    float2 centre = float2(c * cell.x - s * cell.y, s * cell.x + c * cell.y);
    half4 ink = layer.sample(centre);
    half alpha = layer.sample(position).a;
    if (alpha <= 0.0h) { return half4(0); }
    float3 rgb = ink.a > 0.0h ? float3(ink.rgb / ink.a) : float3(1);
    float luminance = dot(rgb, float3(0.299, 0.587, 0.114));
    float coverage = (1.0 - luminance * 0.85) * float(ink.a);
    float radius = sqrt(coverage) * dotSize * 0.72;
    float d = length(p - cell);
    float inside = 1.0 - smoothstep(radius - 0.8, radius + 0.8, d);
    half3 colour = mix(paper.rgb, half3(rgb), half(inside));
    return half4(colour * alpha, alpha);
}
