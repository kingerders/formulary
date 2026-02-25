import SwiftUI
import Charts

// MARK: - Ideal Gas Law  PV = nRT

/// PV diagram with temperature, moles sliders
struct IdealGasLawView: View {
    @State private var temperature: Double = 300  // K
    @State private var moles: Double = 1.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let R = 8.314 // J/(mol·K)

    private func pressure(v: Double) -> Double {
        guard v > 0 else { return 0 }
        return moles * R * temperature / v
    }

    // Volume in liters → converted to m³ for calculation; display in L
    private var isothermPoints: [GraphPoint] {
        stride(from: 5.0, through: 50.0, by: 0.5).map { vLiters in
            let vM3 = vLiters / 1000.0
            let pPa = pressure(v: vM3)
            let pKPa = pPa / 1000
            return GraphPoint(x: vLiters, y: min(pKPa, 600))
        }
    }

    // Second isotherm for comparison
    private var isotherm2Points: [GraphPoint] {
        let t2 = temperature * 1.5
        return stride(from: 5.0, through: 50.0, by: 0.5).map { vLiters in
            let vM3 = vLiters / 1000.0
            let pPa = moles * R * t2 / vM3
            let pKPa = pPa / 1000
            return GraphPoint(x: vLiters, y: min(pKPa, 600))
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Chart {
                // Current isotherm
                ForEach(isothermPoints) { pt in
                    LineMark(x: .value("V", pt.x), y: .value("P", pt.y))
                        .foregroundStyle(Color.appPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                }
                // Higher T isotherm
                ForEach(isotherm2Points) { pt in
                    LineMark(x: .value("V", pt.x), y: .value("P", pt.y))
                        .foregroundStyle(Color.red.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                }
            }
            .chartXScale(domain: 5...50)
            .chartYScale(domain: 0...600)
            .chartXAxisLabel("Volume V (L)")
            .chartYAxisLabel("Pressure P (kPa)")
            .frame(height: 200)
            .padding(.horizontal, 8)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: temperature)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: moles)

            HStack(spacing: 12) {
                InfoChip(label: "T", value: "\(String(format: "%.0f", temperature)) K", color: .red)
                InfoChip(label: "n", value: "\(String(format: "%.1f", moles)) mol", color: .blue)
                InfoChip(label: "P@20L", value: "\(String(format: "%.0f", pressure(v: 0.02) / 1000)) kPa", color: .orange)
            }
            .padding(.horizontal, 8)

            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.appPrimary)
                    .frame(width: 16, height: 3)
                Text("T = \(String(format: "%.0f", temperature)) K")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.red.opacity(0.4))
                    .frame(width: 16, height: 3)
                Text("T = \(String(format: "%.0f", temperature * 1.5)) K")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 4) {
                ParameterSliderView(label: "Temperature", symbol: "T", value: $temperature, range: 100...800, step: 10, unit: "K", color: .red, decimalPlaces: 0)
                ParameterSliderView(label: "Moles", symbol: "n", value: $moles, range: 0.5...5, step: 0.5, unit: "mol", color: .blue)
            }
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - Circle Area  A = πr²

/// Interactive circle showing radius, area, circumference
struct CircleAreaView: View {
    @State private var radius: Double = 3.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var area: Double { .pi * radius * radius }
    private var circumference: Double { 2 * .pi * radius }

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w / 2
                let cy = h / 2
                let maxR = min(w, h) * 0.4
                let displayR = CGFloat(radius / 8.0) * maxR

                Canvas { ctx, _ in
                    // Grid
                    let gridColor = Color.secondary.opacity(0.06)
                    for x in stride(from: 0.0, through: w, by: 20) {
                        ctx.stroke(Path { p in
                            p.move(to: CGPoint(x: x, y: 0))
                            p.addLine(to: CGPoint(x: x, y: h))
                        }, with: .color(gridColor), lineWidth: 0.5)
                    }
                    for y in stride(from: 0.0, through: h, by: 20) {
                        ctx.stroke(Path { p in
                            p.move(to: CGPoint(x: 0, y: y))
                            p.addLine(to: CGPoint(x: w, y: y))
                        }, with: .color(gridColor), lineWidth: 0.5)
                    }

                    // Filled circle
                    let circleRect = CGRect(x: cx - displayR, y: cy - displayR, width: 2 * displayR, height: 2 * displayR)
                    ctx.fill(Path(ellipseIn: circleRect), with: .color(.appPrimary.opacity(0.15)))
                    ctx.stroke(Path(ellipseIn: circleRect), with: .color(.appPrimary), lineWidth: 2.5)

                    // Center dot
                    ctx.fill(Path(ellipseIn: CGRect(x: cx - 3, y: cy - 3, width: 6, height: 6)),
                             with: .color(.red))

                    // Radius line
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: cx, y: cy))
                        p.addLine(to: CGPoint(x: cx + displayR, y: cy))
                    }, with: .color(.red), lineWidth: 2)

                    // Radius label
                    ctx.draw(Text("r = \(String(format: "%.1f", radius))")
                        .font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundStyle(.red),
                             at: CGPoint(x: cx + displayR / 2, y: cy - 14))

                    // Area label
                    ctx.draw(Text("A = \(String(format: "%.1f", area))")
                        .font(.system(size: 13, weight: .bold)).foregroundStyle(Color.appPrimary),
                             at: CGPoint(x: cx, y: cy + 4))

                    // Circumference arc indicator
                    ctx.stroke(Path { p in
                        p.addArc(center: CGPoint(x: cx, y: cy), radius: displayR + 8,
                                 startAngle: .degrees(0), endAngle: .degrees(350), clockwise: false)
                    }, with: .color(.green.opacity(0.6)), style: StrokeStyle(lineWidth: 3, dash: [6, 4]))
                }
            }
            .frame(height: 220)
            .animation(reduceMotion ? nil : .spring(response: 0.3), value: radius)

            HStack(spacing: 12) {
                InfoChip(label: "Radius", value: "\(String(format: "%.1f", radius))", color: .red)
                InfoChip(label: "Area", value: "\(String(format: "%.1f", area))", color: .appPrimary)
                InfoChip(label: "Circumf.", value: "\(String(format: "%.1f", circumference))", color: .green)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 4) {
                ParameterSliderView(label: "Radius", symbol: "r", value: $radius, range: 0.5...8, step: 0.5, color: .red)
            }
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - Exponential Growth / Decay  N(t) = N₀ · e^(kt)

/// Interactive exponential curve with growth or decay
struct ExponentialGrowthView: View {
    @State private var n0: Double = 10.0
    @State private var rate: Double = 0.3
    @State private var isDecay = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var k: Double { isDecay ? -rate : rate }

    private var points: [GraphPoint] {
        stride(from: 0.0, through: 10.0, by: 0.1).map { t in
            GraphPoint(x: t, y: min(n0 * exp(k * t), 200))
        }
    }

    private var halfLife: Double? {
        guard isDecay, rate > 0 else { return nil }
        return log(2) / rate
    }
    private var doublingTime: Double? {
        guard !isDecay, rate > 0 else { return nil }
        return log(2) / rate
    }

    var body: some View {
        VStack(spacing: 12) {
            Chart {
                ForEach(points) { pt in
                    LineMark(x: .value("t", pt.x), y: .value("N", pt.y))
                        .foregroundStyle(isDecay ? Color.orange.gradient : Color.appPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                }
                // N₀ marker
                PointMark(x: .value("t", 0), y: .value("N", n0))
                    .foregroundStyle(.red)
                    .symbolSize(60)
                    .annotation(position: .trailing) {
                        Text("N₀")
                            .font(.system(size: 10, weight: .bold, design: .serif))
                            .foregroundStyle(.red)
                    }

                // Half-life / doubling time marker
                if let hl = halfLife, hl <= 10 {
                    RuleMark(x: .value("t½", hl))
                        .foregroundStyle(.purple.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .annotation(position: .top) {
                            Text("t½")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.purple)
                        }
                }
                if let dt = doublingTime, dt <= 10 {
                    RuleMark(x: .value("t₂", dt))
                        .foregroundStyle(.green.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .annotation(position: .top) {
                            Text("t₂")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.green)
                        }
                }

                RuleMark(y: .value("zero", 0))
                    .foregroundStyle(.secondary.opacity(0.2))
            }
            .chartXScale(domain: 0...10)
            .chartYScale(domain: 0...min(max(n0 * exp(k * 10), n0 * 1.2), 200))
            .chartXAxisLabel("Time t")
            .chartYAxisLabel("N(t)")
            .frame(height: 200)
            .padding(.horizontal, 8)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: n0)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: rate)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: isDecay)

            HStack(spacing: 12) {
                InfoChip(label: "N₀", value: "\(String(format: "%.0f", n0))", color: .red)
                InfoChip(label: isDecay ? "t½" : "t₂",
                         value: isDecay ? "\(String(format: "%.2f", halfLife ?? 0))" : "\(String(format: "%.2f", doublingTime ?? 0))",
                         color: isDecay ? .purple : .green)
                InfoChip(label: "N(10)", value: "\(String(format: "%.1f", min(n0 * exp(k * 10), 9999)))", color: .appPrimary)
            }
            .padding(.horizontal, 8)

            HStack {
                Spacer()
                Toggle(isOn: $isDecay) {
                    Text(isDecay ? "Decay" : "Growth")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .toggleStyle(.button)
                .tint(isDecay ? .orange : .appPrimary)
                Spacer()
            }

            VStack(spacing: 4) {
                ParameterSliderView(label: "Initial value", symbol: "N₀", value: $n0, range: 1...50, step: 1, color: .red, decimalPlaces: 0)
                ParameterSliderView(label: "Rate constant", symbol: "k", value: $rate, range: 0.05...1, step: 0.05, color: .blue, decimalPlaces: 2)
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview("Ideal Gas") { ScrollView { IdealGasLawView().padding() } }
#Preview("Circle") { ScrollView { CircleAreaView().padding() } }
#Preview("Exponential") { ScrollView { ExponentialGrowthView().padding() } }
