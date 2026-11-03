import SwiftUI

/// A round button that splits into a fan of smaller buttons like a drop of
/// liquid, and swallows them back up. The blobs are blurred inside a `Canvas`
/// and cut back with an alpha threshold, so they stretch and merge as they
/// separate (metaballs).
public struct GooeyMenu: View {
    private let symbols: [String]
    private let color: Color
    private let distance: CGFloat
    private let action: (Int) -> Void

    @State private var isOpen = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let mainSize: CGFloat = 56
    private let itemSize: CGFloat = 44

    /// - Parameters:
    ///   - symbols: SF Symbol names, one per menu item.
    ///   - color: Colour of the button and the goo.
    ///   - distance: How far items travel from the main button, in points.
    ///   - action: Called with the index of the tapped item. The menu closes.
    public init(symbols: [String], color: Color = .accentColor, distance: CGFloat = 76, action: @escaping (Int) -> Void) {
        self.symbols = symbols
        self.color = color
        self.distance = distance
        self.action = action
    }

    public var body: some View {
        let width = distance * 2 + itemSize + 16
        let height = distance + itemSize / 2 + mainSize / 2 + 16
        ZStack(alignment: .bottom) {
            Canvas { context, _ in
                context.addFilter(.alphaThreshold(min: 0.5, color: color))
                context.addFilter(.blur(radius: 7))
                context.drawLayer { layer in
                    for id in [-1] + Array(symbols.indices) {
                        if let blob = layer.resolveSymbol(id: id) {
                            layer.draw(blob, at: CGPoint(x: width / 2, y: height - 8 - mainSize / 2))
                        }
                    }
                }
            } symbols: {
                Circle().frame(width: mainSize, height: mainSize).tag(-1)
                ForEach(symbols.indices, id: \.self) { index in
                    Circle()
                        .frame(width: itemSize, height: itemSize)
                        .offset(offset(index))
                        .animation(itemAnimation(index), value: isOpen)
                        .tag(index)
                }
            }
            .frame(width: width, height: height)
            .opacity(reduceMotion ? 0 : 1)
            .accessibilityHidden(true)

            // The real, crisp buttons sit on top of the goo.
            ForEach(symbols.indices, id: \.self) { index in
                Button {
                    action(index)
                    isOpen = false
                } label: {
                    Image(systemName: symbols[index])
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: itemSize, height: itemSize)
                        .background {
                            // Reduce Motion: plain circles that fade in place.
                            if reduceMotion { Circle().fill(color) }
                        }
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .offset(offset(index))
                .opacity(isOpen ? 1 : 0)
                .animation(itemAnimation(index), value: isOpen)
                .allowsHitTesting(isOpen)
                .padding(.bottom, 8 + (mainSize - itemSize) / 2)
            }

            Button {
                isOpen.toggle()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(isOpen ? 45 : 0))
                    .frame(width: mainSize, height: mainSize)
                    .background {
                        if reduceMotion { Circle().fill(color) }
                    }
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
            .animation(.spring(duration: 0.4, bounce: 0.4), value: isOpen)
            .accessibilityLabel(isOpen ? "Close menu" : "Open menu")
        }
        .frame(width: width, height: height)
    }

    /// Items fan out along the upper half-circle.
    private func offset(_ index: Int) -> CGSize {
        guard isOpen || reduceMotion else { return .zero }
        let angle = Double.pi + Double.pi * Double(index + 1) / Double(symbols.count + 1)
        return CGSize(width: cos(angle) * distance, height: sin(angle) * distance)
    }

    private func itemAnimation(_ index: Int) -> Animation {
        if reduceMotion { return .easeInOut(duration: 0.25) }
        let order = isOpen ? index : symbols.count - 1 - index
        return .spring(duration: 0.55, bounce: 0.35).delay(Double(order) * 0.04)
    }
}

#Preview {
    GooeyMenu(symbols: ["camera.fill", "photo.fill", "mic.fill", "doc.fill"], color: .indigo) { index in
        print("tapped", index)
    }
    .padding()
}
