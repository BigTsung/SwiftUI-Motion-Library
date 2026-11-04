// Stitchable shader for Kaleidoscope.swift (SwiftUI layer effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Mirrors one wedge of the layer around the centre, `segments` times, like
/// a kaleidoscope. `rotation` turns the wedge being sampled, so animating it
/// makes the pattern bloom and fold.
[[ stitchable ]] half4 motionKaleidoscope(float2 position, SwiftUI::Layer layer, float2 size, float segments, float rotation) {
    float2 centre = size * 0.5;
    float2 p = position - centre;
    float r = length(p);
    float wedge = 2.0 * M_PI_F / max(segments, 1.0);
    float a = atan2(p.y, p.x);
    a = a - wedge * floor(a / wedge);
    if (a > wedge * 0.5) { a = wedge - a; } // mirror every other half
    a += rotation;
    // Fold the sample radius back into the view so the edges don't go blank.
    float reach = min(size.x, size.y) * 0.5;
    float folded = reach - abs(fmod(r, 2.0 * reach) - reach);
    return layer.sample(centre + folded * float2(cos(a), sin(a)));
}
