import SwiftUI
import Charts

// MARK: - Snell's Law  n₁·sin(θ₁) = n₂·sin(θ₂)

/// Light refraction through a boundary between two media
struct SnellsLawView: View {
    @State private var n1: Double = 1.0    // air
    @State private var n2: Double = 1.5    // glass
    @State private var incidentAngle: Double = 30.0 // degrees
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var refractedAngle: Double {
        let sinTheta2 = (n1 / n2) * sin(incidentAngle * .pi / 180)
        if abs(sinTheta2) > 1 { return 90 } // total internal reflection
        return asin(sinTheta2) * 180 / .pi
    }

    private var isTotalReflection: Bool {
        let sinTheta2 = (n1 / n2) * sin(incidentAngle * .pi / 180)
        return abs(sinTheta2) > 1
    }

    private var criticalAngle: Double? {
        guard n1 > n2 else { return nil }
        return asin(n2 / n1) * 180 / .pi
    }

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let midY = h / 2
                let cx = w / 2
                let rayLen: CGFloat = min(w, h) * 0.4

                Canvas { ctx, _ in
                    // Medium 1 (top) - lighter
                    ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: midY)),
                             with: .color(.cyan.opacity(0.08)))
                    // Medium 2 (bottom) - denser
                    ctx.fill(Path(CGRect(x: 0, y: midY, width: w, height: h - midY)),
                             with: .color(.blue.opacity(0.12)))

                    // Interface line
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: 0, y: midY))
                        p.addLine(to: CGPoint(x: w, y: midY))
                    }, with: .color(.secondary.opacity(0.4)), lineWidth: 2)

                    // Normal (vertical dashed)
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: cx, y: midY - rayLen - 20))
                        p.addLine(to: CGPoint(x: cx, y: midY + rayLen + 20))
                    }, with: .color(.secondary.opacity(0.3)), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))

                    // Incident ray
                    let incRad = incidentAngle * .pi / 180
                    let incStartX = cx - rayLen * CGFloat(sin(incRad))
                    let incStartY = midY - rayLen * CGFloat(cos(incRad))
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: incStartX, y: incStartY))
                        p.addLine(to: CGPoint(x: cx, y: midY))
                    }, with: .color(.yellow), lineWidth: 3)

                    // Arrowhead on incident ray near surface
                    let aFrac: CGFloat = 0.7
                    let arrowX = incStartX + (cx - incStartX) * aFrac
                    let arrowY = incStartY + (midY - incStartY) * aFrac
                    ctx.fill(Path { p in
                        let dx = cx - incStartX
                        let dy = midY - incStartY
                        let len = sqrt(dx * dx + dy * dy)
                        let ux = dx / len
                        let uy = dy / len
                        p.move(to: CGPoint(x: arrowX + ux * 8, y: arrowY + uy * 8))
                        p.addLine(to: CGPoint(x: arrowX - uy * 5, y: arrowY + ux * 5))
                        p.addLine(to: CGPoint(x: arrowX + uy * 5, y: arrowY - ux * 5))
                        p.closeSubpath()
                    }, with: .color(.yellow))

                    // Reflected ray
                    let refStartX = cx + rayLen * CGFloat(sin(incRad))
                    let refStartY = midY - rayLen * CGFloat(cos(incRad))
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: cx, y: midY))
                        p.addLine(to: CGPoint(x: refStartX, y: refStartY))
                    }, with: .color(.yellow.opacity(0.35)), lineWidth: 1.5)

                    // Refracted ray (if not total internal reflection)
                    if !isTotalReflection {
                        let refRad = refractedAngle * .pi / 180
                        let refEndX = cx + rayLen * CGFloat(sin(refRad))
                        let refEndY = midY + rayLen * CGFloat(cos(refRad))
                        ctx.stroke(Path { p in
                            p.move(to: CGPoint(x: cx, y: midY))
                            p.addLine(to: CGPoint(x: refEndX, y: refEndY))
                        }, with: .color(.orange), lineWidth: 3)
                    }

                    // Angle arcs
                    let arcR: CGFloat = 35
                    // θ₁ arc
                    let startA1 = Angle(degrees: -90)
                    let endA1 = Angle(degrees: -90 + incidentAngle)
                    ctx.stroke(Path { p in
                        p.addArc(center: CGPoint(x: cx, y: midY), radius: arcR,
                                 startAngle: startA1, endAngle: endA1, clockwise: false)
                    }, with: .color(.yellow), lineWidth: 1.5)
                    ctx.draw(Text("θ₁").font(.system(size: 10, weight: .bold)).foregroundStyle(.yellow),
                             at: CGPoint(x: cx + 18, y: midY - arcR + 5))

                    // θ₂ arc
                    if !isTotalReflection {
                        let startA2 = Angle(degrees: 90)
                        let endA2 = Angle(degrees: 90 + refractedAngle)
                        ctx.stroke(Path { p in
                            p.addArc(center: CGPoint(x: cx, y: midY), radius: arcR,
                                     startAngle: startA2, endAngle: endA2, clockwise: false)
                        }, with: .color(.orange), lineWidth: 1.5)
                        ctx.draw(Text("θ₂").font(.system(size: 10, weight: .bold)).foregroundStyle(.orange),
                                 at: CGPoint(x: cx + 18, y: midY + arcR - 5))
                    }

                    // Labels
                    ctx.draw(Text("n₁ = \(String(format: "%.2f", n1))")
                        .font(.system(size: 11, weight: .semibold)).foregroundStyle(.cyan),
                             at: CGPoint(x: 50, y: 20))
                    ctx.draw(Text("n₂ = \(String(format: "%.2f", n2))")
                        .font(.system(size: 11, weight: .semibold)).foregroundStyle(.blue),
                             at: CGPoint(x: 50, y: h - 20))

                    if isTotalReflection {
                        ctx.draw(Text("⚡ Total Internal Reflection")
                            .font(.system(size: 12, weight: .bold)).foregroundStyle(.red),
                                 at: CGPoint(x: w / 2, y: h - 20))
                    }
                }
            }
            .frame(height: 240)

            HStack(spacing: 12) {
                InfoChip(label: "θ₁", value: "\(String(format: "%.1f", incidentAngle))°", color: .yellow)
                InfoChip(label: "θ₂", value: isTotalReflection ? "TIR" : "\(String(format: "%.1f", refractedAngle))°", color: isTotalReflection ? .red : .orange)
                if let crit = criticalAngle {
                    InfoChip(label: "θc", value: "\(String(format: "%.1f", crit))°", color: .purple)
                }
            }
            .padding(.horizontal, 8)

            VStack(spacing: 4) {
                ParameterSliderView(label: "Refractive index 1", symbol: "n₁", value: $n1, range: 1.0...2.5, step: 0.05, color: .cyan, decimalPlaces: 2)
                ParameterSliderView(label: "Refractive index 2", symbol: "n₂", value: $n2, range: 1.0...2.5, step: 0.05, color: .blue, decimalPlaces: 2)
                ParameterSliderView(label: "Incident angle", symbol: "θ₁", value: $incidentAngle, range: 0...89, step: 1, unit: "°", color: .orange, decimalPlaces: 0)
            }
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - Doppler Effect  f' = f · (v ± v_obs) / (v ∓ v_src)

/// Animated wave fronts from a moving source
struct DopplerEffectView: View {
    @State private var sourceSpeed: Double = 15.0  // m/s
    @State private var isPlaying = true
    @State private var time: Double = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    private let waveSpeed: Double = 50.0
    private let sourceFreq: Double = 2.0  // Hz

    private var observedFront: Double {
        sourceFreq * waveSpeed / (waveSpeed - sourceSpeed)
    }
    private var observedBehind: Double {
        sourceFreq * waveSpeed / (waveSpeed + sourceSpeed)
    }

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cy = h / 2

                Canvas { ctx, _ in
                    // Background
                    ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h)),
                             with: .color(.black.opacity(0.03)))

                    // Wave fronts
                    let emitInterval = 1.0 / sourceFreq
                    let numWaves = Int(time / emitInterval)
                    let sourceXNow = w * 0.3 + CGFloat(sourceSpeed * time * 2).truncatingRemainder(dividingBy: w * 0.6)

                    for i in max(0, numWaves - 12)...numWaves {
                        let emitT = Double(i) * emitInterval
                        let age = time - emitT
                        guard age >= 0 else { continue }
                        let emitX = w * 0.3 + CGFloat(sourceSpeed * emitT * 2).truncatingRemainder(dividingBy: w * 0.6)
                        let radius = CGFloat(age * waveSpeed * 1.5)
                        guard radius > 0, radius < w else { continue }
                        let opacity = max(0, 1 - age * 0.5)
                        ctx.stroke(Path(ellipseIn: CGRect(x: emitX - radius, y: cy - radius,
                                                           width: 2 * radius, height: 2 * radius)),
                                   with: .color(.appPrimary.opacity(opacity * 0.4)),
                                   lineWidth: 1.5)
                    }

                    // Source
                    let srcX = sourceXNow
                    let sr: CGFloat = 12
                    ctx.fill(Path(ellipseIn: CGRect(x: srcX - sr, y: cy - sr, width: 2 * sr, height: 2 * sr)),
                             with: .color(.red))

                    // Direction arrow
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: srcX + sr + 4, y: cy))
                        p.addLine(to: CGPoint(x: srcX + sr + 20, y: cy))
                        p.addLine(to: CGPoint(x: srcX + sr + 14, y: cy - 4))
                        p.move(to: CGPoint(x: srcX + sr + 20, y: cy))
                        p.addLine(to: CGPoint(x: srcX + sr + 14, y: cy + 4))
                    }, with: .color(.red), lineWidth: 2)

                    // Observer labels
                    ctx.draw(Text("🔊 Higher pitch")
                        .font(.system(size: 10, weight: .semibold)).foregroundStyle(.orange),
                             at: CGPoint(x: w - 50, y: 20))
                    ctx.draw(Text("🔈 Lower pitch")
                        .font(.system(size: 10, weight: .semibold)).foregroundStyle(.cyan),
                             at: CGPoint(x: 50, y: 20))
                }
            }
            .frame(height: 200)

            HStack(spacing: 12) {
                InfoChip(label: "Source f", value: "\(String(format: "%.1f", sourceFreq)) Hz", color: .red)
                InfoChip(label: "f (front)", value: "\(String(format: "%.1f", observedFront)) Hz", color: .orange)
                InfoChip(label: "f (behind)", value: "\(String(format: "%.1f", observedBehind)) Hz", color: .cyan)
            }
            .padding(.horizontal, 8)

            PlaybackControlView(isPlaying: $isPlaying, speed: .constant(1.0)) {
                time = 0; isPlaying = false
            }

            VStack(spacing: 4) {
                ParameterSliderView(label: "Source speed", symbol: "v_s", value: $sourceSpeed, range: 0...45, step: 1, unit: "m/s", color: .red, decimalPlaces: 0)
            }
            .padding(.horizontal, 8)
        }
        .onReceive(timer) { _ in
            guard isPlaying, !reduceMotion else { return }
            time += 0.03
        }
    }
}

// MARK: - Wave Superposition  y = A₁sin(k₁x - ω₁t) + A₂sin(k₂x - ω₂t)

/// Two waves combining — shows interference, beats
struct WaveSuperpositionView: View {
    @State private var a1: Double = 1.0
    @State private var f1: Double = 2.0
    @State private var a2: Double = 1.0
    @State private var f2: Double = 2.5
    @State private var isPlaying = true
    @State private var time: Double = 0.0
    @State private var showIndividual = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    private func wave1(x: Double) -> Double {
        a1 * sin(2 * .pi * f1 * x / 4.0 - 2 * .pi * f1 * time)
    }
    private func wave2(x: Double) -> Double {
        a2 * sin(2 * .pi * f2 * x / 4.0 - 2 * .pi * f2 * time)
    }
    private func combined(x: Double) -> Double { wave1(x: x) + wave2(x: x) }

    private var xRange: [Double] { Array(stride(from: 0, through: 8, by: 0.05)) }

    var body: some View {
        VStack(spacing: 12) {
            Chart {
                if showIndividual {
                    ForEach(xRange, id: \.self) { x in
                        LineMark(x: .value("x", x), y: .value("y1", wave1(x: x)), series: .value("Wave", "1"))
                            .foregroundStyle(.red.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }
                    ForEach(xRange, id: \.self) { x in
                        LineMark(x: .value("x", x), y: .value("y2", wave2(x: x)), series: .value("Wave", "2"))
                            .foregroundStyle(.blue.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }
                }
                ForEach(xRange, id: \.self) { x in
                    LineMark(x: .value("x", x), y: .value("sum", combined(x: x)), series: .value("Wave", "Sum"))
                        .foregroundStyle(Color.appPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                }
                RuleMark(y: .value("zero", 0))
                    .foregroundStyle(.secondary.opacity(0.2))
            }
            .chartYScale(domain: -(a1 + a2 + 0.5)...(a1 + a2 + 0.5))
            .chartXScale(domain: 0...8)
            .chartXAxisLabel("x")
            .chartYAxisLabel("Amplitude")
            .frame(height: 200)
            .padding(.horizontal, 8)

            HStack(spacing: 12) {
                InfoChip(label: "f₁", value: "\(String(format: "%.1f", f1)) Hz", color: .red)
                InfoChip(label: "f₂", value: "\(String(format: "%.1f", f2)) Hz", color: .blue)
                InfoChip(label: "Δf (beat)", value: "\(String(format: "%.1f", abs(f1 - f2))) Hz", color: .purple)
            }
            .padding(.horizontal, 8)

            HStack {
                PlaybackControlView(isPlaying: $isPlaying, speed: .constant(1.0)) {
                    time = 0; isPlaying = false
                }
                Spacer()
                Toggle(isOn: $showIndividual) {
                    Text("Split")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .toggleStyle(.button)
                .tint(.purple)
                .padding(.trailing, 16)
            }

            VStack(spacing: 4) {
                ParameterSliderView(label: "Amplitude 1", symbol: "A₁", value: $a1, range: 0.2...2, step: 0.1, color: .red)
                ParameterSliderView(label: "Frequency 1", symbol: "f₁", value: $f1, range: 0.5...5, step: 0.1, unit: "Hz", color: .red)
                ParameterSliderView(label: "Amplitude 2", symbol: "A₂", value: $a2, range: 0.2...2, step: 0.1, color: .blue)
                ParameterSliderView(label: "Frequency 2", symbol: "f₂", value: $f2, range: 0.5...5, step: 0.1, unit: "Hz", color: .blue)
            }
            .padding(.horizontal, 8)
        }
        .onReceive(timer) { _ in
            guard isPlaying, !reduceMotion else { return }
            time += 0.02
        }
    }
}

#Preview("Snell's Law") { ScrollView { SnellsLawView().padding() } }
#Preview("Doppler") { ScrollView { DopplerEffectView().padding() } }
#Preview("Superposition") { ScrollView { WaveSuperpositionView().padding() } }
