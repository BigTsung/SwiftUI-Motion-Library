// Stitchable shader for Dither.swift (SwiftUI layer effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// Retro ordered dithering: the layer is cut into `pixelSize` blocks, each
/// block's brightness is nudged by a 4x4 Bayer pattern and snapped to one of
/// the palette's colours (darkest first).
[[ stitchable ]] half4 motionDither(float2 position, SwiftUI::Layer layer, float pixelSize, device const half4 *palette, int count) {
    float2 block = floor(position / pixelSize);
    half4 colour = layer.sample((block + 0.5) * pixelSize);
    if (colour.a <= 0.01h) { return half4(0); }
    float3 rgb = float3(colour.rgb / colour.a);
    float luminance = dot(rgb, float3(0.299, 0.587, 0.114));
    const float bayer[16] = { 0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5 };
    int2 b = int2(fmod(block, 4.0));
    float threshold = (bayer[b.y * 4 + b.x] + 0.5) / 16.0 - 0.5;
    int levels = max(count, 2);
    float level = clamp(luminance + threshold / float(levels - 1), 0.0, 1.0);
    int index = clamp(int(round(level * float(levels - 1))), 0, levels - 1);
    half4 shade = palette[min(index, count - 1)];
    return half4(shade.rgb * colour.a, colour.a);
}
