import SwiftUI

/// A clock face with a smoothly sweeping second hand. Live by default; give
/// it a date and the hands spring forward to the new time when it changes,
/// handy for time zones, alarms or "time travel" pickers.
///
/// ```swift
/// AnalogClock()                         // live
/// AnalogClock(date: meetingTime)        // hands spring to each new time
///     .frame(width: 160, height: 160)
/// ```
public struct AnalogClock: View {
    private let date: Date?
    private let color: Color
    private let accent: Color
    private let timeZone: TimeZone

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - date: The time to show. Leave nil for the current time, live.
    ///   - color: Colour of the face markings and the hour and minute hands.
    ///   - accent: Colour of the second hand.
    ///   - timeZone: Time zone the hands show.
    public init(date: Date? = nil, color: Color = .primary, accent: Color = .orange, timeZone: TimeZone = .current) {
        self.date = date
        self.color = color
        self.accent = accent
        self.timeZone = timeZone
    }

    public var body: some View {
        Group {
            if let date {
                ClockFace(seconds: localSeconds(date), color: color, accent: accent)
                    .animation(reduceMotion ? .easeInOut(duration: 0.3) : .spring(duration: 0.9, bounce: 0.3), value: date)
            } else if reduceMotion {
                // Reduce Motion: the second hand ticks instead of sweeping.
                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    ClockFace(seconds: floor(localSeconds(timeline.date)), color: color, accent: accent)
                }
            } else {
                TimelineView(.animation) { timeline in
                    ClockFace(seconds: localSeconds(timeline.date), color: color, accent: accent)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("Clock")
        .accessibilityValue((date ?? .now).formatted(date: .omitted, time: .shortened))
    }

    /// Seconds since a local midnight long ago, so the hands only ever move
    /// forward as time goes on.
    private func localSeconds(_ date: Date) -> Double {
        date.timeIntervalSinceReferenceDate + Double(timeZone.secondsFromGMT(for: date))
    }
}

/// The face and hands for a count of local seconds. Animatable so a change of
/// time turns the hands rather than jumping.
struct ClockFace: View, Animatable {
    var seconds: Double
    var color: Color
    var accent: Color

    var animatableData: Double {
        get { seconds }
        set { seconds = newValue }
    }

    var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            let centre = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = side / 2
            context.stroke(Path(ellipseIn: CGRect(x: centre.x - radius + 1, y: centre.y - radius + 1, width: side - 2, height: side - 2)), with: .color(color.opacity(0.25)), lineWidth: 2)
            for tick in 0..<60 {
                let major = tick % 5 == 0
                let angle = Double(tick) / 60 * 2 * .pi
                let outer = radius * 0.92, inner = radius * (major ? 0.8 : 0.87)
                var path = Path()
                path.move(to: point(centre, angle, inner))
                path.addLine(to: point(centre, angle, outer))
                context.stroke(path, with: .color(color.opacity(major ? 0.9 : 0.35)), style: StrokeStyle(lineWidth: major ? 2.5 : 1, lineCap: .round))
            }
            let s = seconds.truncatingRemainder(dividingBy: 43_200) // 12 h
            hand(&context, centre, angle: s / 43_200 * 2 * .pi, length: radius * 0.5, width: side * 0.045, color: color)
            hand(&context, centre, angle: s.truncatingRemainder(dividingBy: 3600) / 3600 * 2 * .pi, length: radius * 0.75, width: side * 0.03, color: color)
            let secondAngle = s.truncatingRemainder(dividingBy: 60) / 60 * 2 * .pi
            var second = Path()
            second.move(to: point(centre, secondAngle + .pi, radius * 0.18))
            second.addLine(to: point(centre, secondAngle, radius * 0.85))
            context.stroke(second, with: .color(accent), style: StrokeStyle(lineWidth: max(1, side * 0.012), lineCap: .round))
            let dot = side * 0.035
            context.fill(Path(ellipseIn: CGRect(x: centre.x - dot, y: centre.y - dot, width: dot * 2, height: dot * 2)), with: .color(accent))
        }
    }

    /// A point `distance` from the centre at a clock angle (0 = 12 o'clock).
    private func point(_ centre: CGPoint, _ angle: Double, _ distance: Double) -> CGPoint {
        CGPoint(x: centre.x + sin(angle) * distance, y: centre.y - cos(angle) * distance)
    }

    private func hand(_ context: inout GraphicsContext, _ centre: CGPoint, angle: Double, length: Double, width: Double, color: Color) {
        var path = Path()
        path.move(to: point(centre, angle + .pi, length * 0.12))
        path.addLine(to: point(centre, angle, length))
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
    }
}

#Preview {
    struct Demo: View {
        @State private var date = Date()
        var body: some View {
            HStack(spacing: 30) {
                AnalogClock().frame(width: 120)
                AnalogClock(date: date, accent: .pink)
                    .frame(width: 120)
                    .onTapGesture { date.addTimeInterval(3 * 3600 + 1200) }
            }
        }
    }
    return Demo()
}
