import SwiftUI
import Charts

/// Animated unit circle showing sine/cosine wave visualization
struct SineCosineView: View {
    @State private var isPlaying = true
    @State private var speed: Double = 1.0
    @State private var angle: Double = 0.0
    @State private var showCosine = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    private var sinePoints: [GraphPoint] {
        stride(from: 0.0, through: 4 * Double.pi, by: 0.1).map { x in
            GraphPoint(x: x, y: sin(x + angle))
        }
    }

    private var cosinePoints: [GraphPoint] {
        stride(from: 0.0, through: 4 * Double.pi, by: 0.1).map { x in
            GraphPoint(x: x, y: cos(x + angle))
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Chart {
                ForEach(sinePoints) { pt in
                    LineMark(x: .value("x", pt.x), y: .value("y", pt.y))
                        .foregroundStyle(Color.red.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                }

                if showCosine {
                    ForEach(cosinePoints) { pt in
                        LineMark(x: .value("x", pt.x), y: .value("y", pt.y))
                            .foregroundStyle(Color.blue.gradient)
                            .lineStyle(StrokeStyle(lineWidth: 2.5))
                    }
                }

                RuleMark(y: .value("zero", 0))
                    .foregroundStyle(Color.gray.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 0.5))
            }
            .chartYScale(domain: -1.5...1.5)
            .chartXScale(domain: 0...(4 * Double.pi))
            .chartXAxisLabel("x (radians)")
            .chartYAxisLabel("y")
            .frame(height: 220)
            .padding(.horizontal, 8)

            HStack(spacing: 12) {
                InfoChip(label: "Angle", value: String(format: "%.0f°", angle.truncatingRemainder(dividingBy: 2 * Double.pi) * 180 / Double.pi), color: Color.appPrimary)
                InfoChip(label: "sin(θ)", value: String(format: "%.3f", sin(angle)), color: Color.red)
                InfoChip(label: "cos(θ)", value: String(format: "%.3f", cos(angle)), color: Color.blue)
            }
            .padding(.horizontal, 8)

            HStack {
                PlaybackControlView(isPlaying: $isPlaying, speed: $speed) {
                    angle = 0
                }

                Spacer()

                Toggle(isOn: $showCosine) {
                    Text("cos")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .toggleStyle(.button)
                .tint(Color.blue)
                .padding(.trailing, 16)
            }
        }
        .onReceive(timer) { _ in
            guard isPlaying else { return }
            if reduceMotion { return }
            angle += 0.02 * speed
        }
    }
}

/// Pythagorean theorem: a² + b² = c²
struct PythagoreanView: View {
    @State private var a: Double = 3.0
    @State private var b: Double = 4.0
    @Environment(\.colorScheme) private var colorScheme

    private var c: Double { sqrt(a * a + b * b) }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                GeometryReader { geo in
                    let size = geo.size
                    let scale = min(size.width, size.height) / (max(a, b) * 3.0)
                    let cx = size.width / 2
                    let cy = size.height / 2
                    let x0 = cx - CGFloat(b * scale) / 2
                    let y0 = cy + CGFloat(a * scale) / 2

                    Path { p in
                        p.move(to: CGPoint(x: x0, y: y0))
                        p.addLine(to: CGPoint(x: x0 + CGFloat(b * scale), y: y0))
                        p.addLine(to: CGPoint(x: x0, y: y0 - CGFloat(a * scale)))
                        p.closeSubpath()
                    }
                    .fill(Color.appPrimary.opacity(0.15))
                    .overlay(
                        Path { p in
                            p.move(to: CGPoint(x: x0, y: y0))
                            p.addLine(to: CGPoint(x: x0 + CGFloat(b * scale), y: y0))
                            p.addLine(to: CGPoint(x: x0, y: y0 - CGFloat(a * scale)))
                            p.closeSubpath()
                        }
                        .stroke(Color.appPrimary, lineWidth: 2.5)
                    )

                    Text("a = " + String(format: "%.1f", a))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.red)
                        .position(x: x0 - 28, y: cy)

                    Text("b = " + String(format: "%.1f", b))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.blue)
                        .position(x: cx, y: y0 + 18)

                    Text("c = " + String(format: "%.2f", c))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.orange)
                        .position(x: cx + 20, y: cy - 10)
                }
            }
            .frame(height: 220)

            HStack(spacing: 16) {
                InfoChip(label: "a²", value: String(format: "%.1f", a * a), color: Color.red)
                InfoChip(label: "b²", value: String(format: "%.1f", b * b), color: Color.blue)
                InfoChip(label: "c²", value: String(format: "%.2f", c * c), color: Color.orange)
                InfoChip(label: "a²+b²", value: String(format: "%.1f", a * a + b * b), color: Color.green)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 4) {
                ParameterSliderView(label: "Side a", symbol: "a", value: $a, range: 1...10, step: 0.5, color: Color.red)
                ParameterSliderView(label: "Side b", symbol: "b", value: $b, range: 1...10, step: 0.5, color: Color.blue)
            }
            .padding(.horizontal, 8)
        }
    }
}
