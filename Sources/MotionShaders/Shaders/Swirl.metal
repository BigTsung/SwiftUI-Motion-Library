// Stitchable shader for Swirl.swift (SwiftUI distortion effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Twists the view around `centre` like water going down a drain: pixels
/// within `radius` are rotated, most at the centre and none at the edge.
[[ stitchable ]] float2 motionSwirl(float2 position, float2 centre, float radius, float strength) {
    float2 offset = position - centre;
    float d = length(offset);
    if (d >= radius) { return position; }
    float t = 1.0 - d / radius;
    float angle = strength * t * t;
    float c = cos(angle), s = sin(angle);
    return centre + float2(c * offset.x - s * offset.y, s * offset.x + c * offset.y);
}
