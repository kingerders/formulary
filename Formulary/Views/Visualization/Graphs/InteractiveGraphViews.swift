import SwiftUI
import Charts

/// Interactive parabola: y = ax² + bx + c with real-time sliders
struct QuadraticGraphView: View {
    @State private var a: Double = 1.0
    @State private var b: Double = 0.0
    @State private var c: Double = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var points: [GraphPoint] {
        stride(from: -5.0, through: 5.0, by: 0.1).map { x in
            GraphPoint(x: x, y: a * x * x + b * x + c)
        }
    }

    private var discriminant: Double { b * b - 4 * a * c }

    private var roots: [Double] {
        guard a != 0 else { return [] }
        let d = discriminant
        if d < 0 { return [] }
        if d == 0 { return [-b / (2 * a)] }
        let sqrtD = sqrt(d)
        return [(-b - sqrtD) / (2 * a), (-b + sqrtD) / (2 * a)]
    }

    private var vertex: (x: Double, y: Double) {
        guard a != 0 else { return (0, c) }
        let vx = -b / (2 * a)
        let vy = a * vx * vx + b * vx + c
        return (vx, vy)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Chart
            Chart {
                ForEach(points) { pt in
                    LineMark(x: .value("x", pt.x), y: .value("y", pt.y))
                        .foregroundStyle(Color.appPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                }

                // Vertex
                PointMark(x: .value("x", vertex.x), y: .value("y", vertex.y))
                    .foregroundStyle(.orange)
                    .symbolSize(60)
                    .annotation(position: a > 0 ? .bottom : .top) {
                        Text("Vertex")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.orange)
                    }

                // Roots
                ForEach(roots, id: \.self) { root in
                    if root >= -5 && root <= 5 {
                        PointMark(x: .value("x", root), y: .value("y", 0))
                            .foregroundStyle(.green)
                            .symbolSize(50)
                    }
                }

                // Axis lines
                RuleMark(y: .value("zero", 0))
                    .foregroundStyle(.secondary.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 0.5))
                RuleMark(x: .value("zero", 0))
                    .foregroundStyle(.secondary.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 0.5))
            }
            .chartYScale(domain: -10...10)
            .chartXScale(domain: -5...5)
            .chartXAxisLabel("x")
            .chartYAxisLabel("y")
            .frame(height: 220)
            .padding(.horizontal, 8)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: a)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: b)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: c)
            .accessibilityLabel("Parabola graph showing y = \(String(format: "%.1f", a))x² + \(String(format: "%.1f", b))x + \(String(format: "%.1f", c))")

            // Info strip
            HStack(spacing: 16) {
                InfoChip(label: "Δ", value: String(format: "%.1f", discriminant),
                         color: discriminant >= 0 ? .green : .red)
                InfoChip(label: "Roots", value: "\(roots.count)",
                         color: roots.isEmpty ? .red : .green)
                InfoChip(label: "Vertex",
                         value: "(\(String(format: "%.1f", vertex.x)), \(String(format: "%.1f", vertex.y)))",
                         color: .orange)
            }
            .padding(.horizontal, 8)

            // Sliders
            VStack(spacing: 4) {
                ParameterSliderView(label: "Leading coefficient", symbol: "a", value: $a, range: -5...5, step: 0.1, color: .red)
                ParameterSliderView(label: "Linear coefficient", symbol: "b", value: $b, range: -10...10, step: 0.1, color: .blue)
                ParameterSliderView(label: "Constant term", symbol: "c", value: $c, range: -10...10, step: 0.1, color: .green)
            }
            .padding(.horizontal, 8)
        }
    }
}

/// Normal distribution bell curve: adjust μ and σ
struct NormalDistributionView: View {
    @State private var mu: Double = 0.0
    @State private var sigma: Double = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private func normalPDF(_ x: Double) -> Double {
        let coeff = 1.0 / (sigma * sqrt(2.0 * .pi))
        let exponent = -0.5 * pow((x - mu) / sigma, 2)
        return coeff * exp(exponent)
    }

    private var points: [GraphPoint] {
        stride(from: -6.0, through: 6.0, by: 0.05).map { x in
            GraphPoint(x: x, y: normalPDF(x))
        }
    }

    // Area within 1σ, 2σ, 3σ
    private var stdDevRegions: [(label: String, from: Double, to: Double, color: Color)] {
        [
            ("1σ (68.3%)", mu - sigma, mu + sigma, Color.blue.opacity(0.25)),
            ("2σ (95.5%)", mu - 2 * sigma, mu + 2 * sigma, Color.blue.opacity(0.12)),
            ("3σ (99.7%)", mu - 3 * sigma, mu + 3 * sigma, Color.blue.opacity(0.06)),
        ]
    }

    var body: some View {
        VStack(spacing: 12) {
            Chart {
                // Shaded 1σ region
                ForEach(points.filter { $0.x >= mu - sigma && $0.x <= mu + sigma }) { pt in
                    AreaMark(x: .value("x", pt.x), y: .value("y", pt.y))
                        .foregroundStyle(Color.appPrimary.opacity(0.2))
                }

                // Curve
                ForEach(points) { pt in
                    LineMark(x: .value("x", pt.x), y: .value("y", pt.y))
                        .foregroundStyle(Color.appPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                }

                // Mean line
                RuleMark(x: .value("μ", mu))
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    .annotation(position: .top) {
                        Text("μ")
                            .font(.system(size: 11, weight: .bold, design: .serif))
                            .foregroundStyle(.orange)
                    }

                // σ markers
                RuleMark(x: .value("-σ", mu - sigma))
                    .foregroundStyle(.green.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                RuleMark(x: .value("+σ", mu + sigma))
                    .foregroundStyle(.green.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
            }
            .chartYScale(domain: 0...0.5)
            .chartXScale(domain: -6...6)
            .frame(height: 220)
            .padding(.horizontal, 8)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: mu)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: sigma)

            HStack(spacing: 16) {
                InfoChip(label: "Peak", value: String(format: "%.3f", normalPDF(mu)), color: .appPrimary)
                InfoChip(label: "68.3%", value: "μ ± \(String(format: "%.1f", sigma))", color: .green)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 4) {
                ParameterSliderView(label: "Mean", symbol: "μ", value: $mu, range: -4...4, step: 0.1, color: .orange)
                ParameterSliderView(label: "Std Deviation", symbol: "σ", value: $sigma, range: 0.2...3.0, step: 0.1, color: .green)
            }
            .padding(.horizontal, 8)
        }
    }
}

/// Projectile motion: v₀ and θ sliders with trajectory plot
struct ProjectileMotionView: View {
    @State private var v0: Double = 20.0
    @State private var theta: Double = 45.0
    @State private var isPlaying = false
    @State private var animationTime: Double = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let g = 9.81
    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()

    private var thetaRad: Double { theta * .pi / 180 }
    private var totalTime: Double { 2 * v0 * sin(thetaRad) / g }
    private var maxHeight: Double { pow(v0 * sin(thetaRad), 2) / (2 * g) }
    private var range: Double { v0 * v0 * sin(2 * thetaRad) / g }

    private var trajectoryPoints: [GraphPoint] {
        guard totalTime > 0 else { return [] }
        return stride(from: 0, through: totalTime, by: totalTime / 100).map { t in
            let x = v0 * cos(thetaRad) * t
            let y = v0 * sin(thetaRad) * t - 0.5 * g * t * t
            return GraphPoint(x: x, y: max(y, 0))
        }
    }

    private var currentPosition: (x: Double, y: Double) {
        let t = min(animationTime, totalTime)
        let x = v0 * cos(thetaRad) * t
        let y = max(v0 * sin(thetaRad) * t - 0.5 * g * t * t, 0)
        return (x, y)
    }

    var body: some View {
        VStack(spacing: 12) {
            Chart {
                // Trajectory
                ForEach(trajectoryPoints) { pt in
                    LineMark(x: .value("x", pt.x), y: .value("y", pt.y))
                        .foregroundStyle(Color.appPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                }

                // Ground line
                RuleMark(y: .value("ground", 0))
                    .foregroundStyle(.brown.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1))

                // Current ball position
                if isPlaying || animationTime > 0 {
                    PointMark(x: .value("x", currentPosition.x), y: .value("y", currentPosition.y))
                        .foregroundStyle(.red)
                        .symbolSize(80)
                }

                // Max height marker
                PointMark(x: .value("x", range / 2), y: .value("y", maxHeight))
                    .foregroundStyle(.orange)
                    .symbolSize(40)
                    .annotation(position: .top) {
                        Text("H_max")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(.orange)
                    }
            }
            .chartYScale(domain: 0...max(maxHeight * 1.2, 1))
            .chartXScale(domain: 0...max(range * 1.1, 1))
            .frame(height: 200)
            .padding(.horizontal, 8)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: v0)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: theta)
            .onReceive(timer) { _ in
                guard isPlaying else { return }
                animationTime += 0.03 * 2
                if animationTime >= totalTime {
                    animationTime = 0
                }
            }

            // Info
            HStack(spacing: 12) {
                InfoChip(label: "Range", value: String(format: "%.1fm", range), color: .blue)
                InfoChip(label: "Height", value: String(format: "%.1fm", maxHeight), color: .orange)
                InfoChip(label: "Time", value: String(format: "%.1fs", totalTime), color: .green)
            }
            .padding(.horizontal, 8)

            PlaybackControlView(isPlaying: $isPlaying, speed: .constant(1.0)) {
                animationTime = 0
                isPlaying = false
            }

            VStack(spacing: 4) {
                ParameterSliderView(label: "Initial velocity", symbol: "v₀", value: $v0, range: 5...50, step: 1, unit: "m/s", color: .red, decimalPlaces: 0)
                ParameterSliderView(label: "Launch angle", symbol: "θ", value: $theta, range: 5...85, step: 1, unit: "°", color: .blue, decimalPlaces: 0)
            }
            .padding(.horizontal, 8)
        }
    }
}

/// Helper for chart data
struct GraphPoint: Identifiable {
    let id = UUID()
    let x: Double
    let y: Double
}

/// Small info chip showing a label and value
struct InfoChip: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview("Quadratic") {
    ScrollView {
        QuadraticGraphView()
            .padding()
    }
}

#Preview("Normal") {
    ScrollView {
        NormalDistributionView()
            .padding()
    }
}

#Preview("Projectile") {
    ScrollView {
        ProjectileMotionView()
            .padding()
    }
}
