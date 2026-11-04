// Stitchable shader for Voronoi.swift (SwiftUI colour effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// A cheap, stable hash of a 2D point into 0...1, two values at once.
static float2 motionHash2(float2 p) {
    p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

/// Slowly drifting Voronoi cells: each pixel takes the colour of its nearest
/// moving seed (picked from `palette`), and the borders between cells are
/// drawn as soft dark seams.
[[ stitchable ]] half4 motionVoronoi(float2 position, half4 colour, float time, float scale, device const half4 *palette, int count) {
    float2 p = position / scale;
    float2 cell = floor(p);
    float nearest = 8.0, second = 8.0;
    float2 nearestCell = float2(0);
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            float2 neighbour = cell + float2(x, y);
            float2 h = motionHash2(neighbour);
            float2 seed = neighbour + 0.5 + 0.4 * sin(time + 6.2831 * h);
            float d = length(p - seed);
            if (d < nearest) { second = nearest; nearest = d; nearestCell = neighbour; }
            else if (d < second) { second = d; }
        }
    }
    int index = int(motionHash2(nearestCell + 3.0).x * float(count)) % max(count, 1);
    half4 fill = palette[index];
    float seam = smoothstep(0.0, 0.08, second - nearest);
    float glow = 1.0 - nearest * 0.35;
    return half4(fill.rgb * half(seam * glow), 1.0h) * colour.a;
}
