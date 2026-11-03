// Stitchable shader for Pixellate.swift (SwiftUI layer/distortion/colour effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Samples one colour per `size` × `size` cell.
[[ stitchable ]] half4 motionPixellate(float2 position, SwiftUI::Layer layer, float size) {
    if (size <= 1.0) { return layer.sample(position); }
    float2 cell = (floor(position / size) + 0.5) * size;
    return layer.sample(cell);
}
