// Stitchable shader for GlassLens.swift (SwiftUI layer effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// A round glass lens over the layer: magnifies the middle, bends the light
/// harder towards the rim (splitting the colours a little), adds a bright rim
/// and specular highlight, and drops a soft shadow just outside.
[[ stitchable ]] half4 motionGlassLens(float2 position, SwiftUI::Layer layer, float2 centre, float radius, float magnification) {
    float2 offset = position - centre;
    float d = length(offset);
    float u = d / radius;
    if (u >= 1.0) {
        half4 colour = layer.sample(position);
        // Soft shadow ring outside the rim.
        float shadow = (1.0 - smoothstep(1.0, 1.12, u)) * 0.22;
        return half4(colour.rgb * half(1.0 - shadow), colour.a);
    }
    // Strong magnification in the middle easing to none at the rim.
    float scale = mix(1.0 / magnification, 1.0, pow(u, 3.0));
    float split = 0.035 * pow(u, 4.0);
    half4 g = layer.sample(centre + offset * scale);
    half r = layer.sample(centre + offset * (scale + split)).r;
    half b = layer.sample(centre + offset * (scale - split)).b;
    half4 colour = half4(r, g.g, b, g.a);
    // Bright rim, and a highlight up and to the left.
    float rim = smoothstep(0.86, 1.0, u) * 0.35;
    float2 light = centre + float2(-0.38, -0.42) * radius;
    float spec = (1.0 - smoothstep(0.0, radius * 0.32, length(position - light))) * 0.45;
    half glow = half(rim + spec);
    colour.rgb = colour.rgb + glow * (1.0h - colour.rgb);
    colour.a = max(colour.a, glow);
    return colour;
}
