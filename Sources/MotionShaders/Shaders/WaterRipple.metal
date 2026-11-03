// Stitchable shader for WaterRipple.swift (SwiftUI layer/distortion/colour effect).

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

/// A ring wave travels out from `origin`, pushing pixels along the radius;
/// it rings at `frequency`, fades with `decay`, and brightens its crests.
[[ stitchable ]] half4 motionRipple(float2 position, SwiftUI::Layer layer,
                                    float2 origin, float time,
                                    float amplitude, float frequency, float decay, float speed) {
    float distance = length(position - origin);
    // Each pixel starts moving once the wave front reaches it.
    float local = max(0.0, time - distance / speed);
    float wave = amplitude * sin(frequency * local) * exp(-decay * local);
    float2 direction = distance > 0.001 ? (position - origin) / distance : float2(0);
    half4 color = layer.sample(position + wave * direction);
    color.rgb += half(0.25 * (wave / max(amplitude, 0.001))) * color.a;
    return color;
}
