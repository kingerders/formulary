import SwiftUI
import Charts

// MARK: - Ohm's Law  V = IR

/// Interactive V-I graph with adjustable resistance
struct OhmsLawView: View {
    @State private var resistance: Double = 5.0
    @State private var current: Double = 2.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var voltage: Double { current * resistance }

    private var linePoints: [GraphPoint] {
        stride(from: 0.0, through: 10.0, by: 0.1).map { i in
            GraphPoint(x: i, y: i * resistance)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Chart {
                ForEach(linePoints) { pt in
                    LineMark(x: .value("I (A)", pt.x), y: .value("V (V)", pt.y))
                        .foregroundStyle(Color.appPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                }
                PointMark(x: .value("I", current), y: .value("V", voltage))
                    .foregroundStyle(.red)
                    .symbolSize(80)
                    .annotation(position: .topLeading) {
                        Text("\(String(format: "%.1f", voltage))V")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.red)
                    }
                RuleMark(y: .value("zero", 0))
                    .foregroundStyle(.secondary.opacity(0.2))
                RuleMark(x: .value("zero", 0))
                    .foregroundStyle(.secondary.opacity(0.2))
            }
            .chartXScale(domain: 0...10)
            .chartYScale(domain: 0...50)
            .chartXAxisLabel("Current I (A)")
            .chartYAxisLabel("Voltage V (V)")
            .frame(height: 200)
            .padding(.horizontal, 8)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: resistance)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: current)

            HStack(spacing: 12) {
                InfoChip(label: "Voltage", value: "\(String(format: "%.1f", voltage)) V", color: .red)
                InfoChip(label: "Current", value: "\(String(format: "%.1f", current)) A", color: .blue)
                InfoChip(label: "Resistance", value: "\(String(format: "%.1f", resistance)) Ω", color: .orange)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 4) {
                ParameterSliderView(label: "Resistance", symbol: "R", value: $resistance, range: 0.5...10, step: 0.5, unit: "Ω", color: .orange)
                ParameterSliderView(label: "Current", symbol: "I", value: $current, range: 0...10, step: 0.1, unit: "A", color: .blue)
            }
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - Hooke's Law  F = -kx

/// Animated spring with adjustable spring constant and displacement
struct HookesLawView: View {
    @State private var springK: Double = 3.0
    @State private var displacement: Double = 2.0
    @State private var isAnimating = false
    @State private var animPhase: Double = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    private var force: Double { springK * displacement }
    private var currentDisplacement: Double {
        isAnimating ? displacement * sin(animPhase) : displacement
    }

    var body: some View {
        VStack(spacing: 12) {
            // Spring canvas
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let anchorX: CGFloat = 40
                let restY = h / 2
                let maxStretch: CGFloat = (w - 120) / 2
                let stretchPx = CGFloat(currentDisplacement / 5.0) * maxStretch
                let massX = w / 2 + stretchPx

                Canvas { ctx, _ in
                    // Wall
                    ctx.fill(Path(CGRect(x: 0, y: h * 0.15, width: 10, height: h * 0.7)),
                             with: .color(.secondary.opacity(0.3)))

                    // Spring coils
                    let coils = 12
                    let springPath = Path { p in
                        p.move(to: CGPoint(x: anchorX, y: restY))
                        let segW = (massX - anchorX - 30) / CGFloat(coils)
                        let amp: CGFloat = 14
                        for i in 0..<coils {
                            let x1 = anchorX + segW * (CGFloat(i) + 0.5)
                            let y1 = restY + (i.isMultiple(of: 2) ? -amp : amp)
                            let x2 = anchorX + segW * CGFloat(i + 1)
                            let y2 = restY
                            p.addQuadCurve(to: CGPoint(x: x2, y: y2),
                                           control: CGPoint(x: x1, y: y1))
                        }
                    }
                    ctx.stroke(springPath, with: .color(.appPrimary), lineWidth: 2.5)

                    // Mass block
                    let blockSize: CGFloat = 36
                    let blockRect = CGRect(x: massX - blockSize / 2, y: restY - blockSize / 2,
                                           width: blockSize, height: blockSize)
                    ctx.fill(Path(roundedRect: blockRect, cornerRadius: 6),
                             with: .color(.red.opacity(0.8)))
                    ctx.draw(Text("m").font(.system(size: 14, weight: .bold)).foregroundStyle(.white),
                             at: CGPoint(x: massX, y: restY))

                    // Equilibrium line
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: w / 2, y: h * 0.1))
                        p.addLine(to: CGPoint(x: w / 2, y: h * 0.9))
                    }, with: .color(.secondary.opacity(0.2)), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))

                    // Force arrow
                    if abs(currentDisplacement) > 0.1 {
                        let arrowDir: CGFloat = currentDisplacement > 0 ? -1 : 1
                        let arrowLen = min(abs(CGFloat(force)) * 8, w * 0.3)
                        let arrowY = restY + blockSize / 2 + 18
                        let arrowStart = massX
                        let arrowEnd = arrowStart + arrowDir * arrowLen
                        ctx.stroke(Path { p in
                            p.move(to: CGPoint(x: arrowStart, y: arrowY))
                            p.addLine(to: CGPoint(x: arrowEnd, y: arrowY))
                            p.addLine(to: CGPoint(x: arrowEnd - arrowDir * 8, y: arrowY - 5))
                            p.move(to: CGPoint(x: arrowEnd, y: arrowY))
                            p.addLine(to: CGPoint(x: arrowEnd - arrowDir * 8, y: arrowY + 5))
                        }, with: .color(.green), lineWidth: 2)
                        ctx.draw(Text("F").font(.system(size: 11, weight: .bold)).foregroundStyle(.green),
                                 at: CGPoint(x: (arrowStart + arrowEnd) / 2, y: arrowY - 12))
                    }

                    // Displacement label
                    ctx.draw(Text("x = \(String(format: "%.1f", currentDisplacement))")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(.secondary),
                             at: CGPoint(x: massX, y: restY - blockSize / 2 - 12))
                }
            }
            .frame(height: 180)

            HStack(spacing: 12) {
                InfoChip(label: "Force", value: "\(String(format: "%.1f", force)) N", color: .green)
                InfoChip(label: "Spring k", value: "\(String(format: "%.1f", springK)) N/m", color: .orange)
                InfoChip(label: "Energy", value: "\(String(format: "%.2f", 0.5 * springK * displacement * displacement)) J", color: .purple)
            }
            .padding(.horizontal, 8)

            HStack {
                PlaybackControlView(isPlaying: $isAnimating, speed: .constant(1.0)) {
                    animPhase = 0
                    isAnimating = false
                }
            }

            VStack(spacing: 4) {
                ParameterSliderView(label: "Spring constant", symbol: "k", value: $springK, range: 0.5...10, step: 0.5, unit: "N/m", color: .orange)
                ParameterSliderView(label: "Displacement", symbol: "x", value: $displacement, range: 0.5...5, step: 0.5, unit: "m", color: .red)
            }
            .padding(.horizontal, 8)
        }
        .onReceive(timer) { _ in
            guard isAnimating, !reduceMotion else { return }
            let omega = sqrt(springK / 1.0) // m=1
            animPhase += 0.02 * omega
        }
    }
}

// MARK: - Simple Harmonic Motion  x(t) = A·sin(ωt + φ)

/// Animated oscillating mass + real-time sine graph
struct SimpleHarmonicMotionView: View {
    @State private var amplitude: Double = 3.0
    @State private var frequency: Double = 1.0
    @State private var isPlaying = true
    @State private var time: Double = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    private var omega: Double { 2 * .pi * frequency }
    private var currentX: Double { amplitude * sin(omega * time) }
    private var period: Double { frequency > 0 ? 1.0 / frequency : 0 }

    private var wavePoints: [GraphPoint] {
        stride(from: 0.0, through: 3.0, by: 0.02).map { t in
            GraphPoint(x: t, y: amplitude * sin(omega * t))
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Mass-spring animation
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let centerX = w / 2
                let baseY: CGFloat = 30
                let maxHang: CGFloat = h - 80
                let offset = CGFloat(currentX / 5.0) * (maxHang * 0.3)
                let massY = h * 0.5 + offset

                Canvas { ctx, _ in
                    // Ceiling
                    ctx.fill(Path(CGRect(x: centerX - 40, y: 0, width: 80, height: 8)),
                             with: .color(.secondary.opacity(0.3)))

                    // Spring
                    let coils = 10
                    let springPath = Path { p in
                        p.move(to: CGPoint(x: centerX, y: baseY))
                        let segH = (massY - baseY - 20) / CGFloat(coils)
                        let amp: CGFloat = 16
                        for i in 0..<coils {
                            let y1 = baseY + segH * (CGFloat(i) + 0.5)
                            let x1 = centerX + (i.isMultiple(of: 2) ? -amp : amp)
                            let x2 = centerX
                            let y2 = baseY + segH * CGFloat(i + 1)
                            p.addQuadCurve(to: CGPoint(x: x2, y: y2),
                                           control: CGPoint(x: x1, y: y1))
                        }
                    }
                    ctx.stroke(springPath, with: .color(.appPrimary), lineWidth: 2.5)

                    // Mass
                    let r: CGFloat = 22
                    let circle = Path(ellipseIn: CGRect(x: centerX - r, y: massY - r, width: 2 * r, height: 2 * r))
                    ctx.fill(circle, with: .color(.red.opacity(0.85)))
                    ctx.draw(Text("m").font(.system(size: 13, weight: .bold)).foregroundStyle(.white),
                             at: CGPoint(x: centerX, y: massY))

                    // Equilibrium
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: centerX - 50, y: h * 0.5))
                        p.addLine(to: CGPoint(x: centerX + 50, y: h * 0.5))
                    }, with: .color(.secondary.opacity(0.3)), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
            }
            .frame(height: 200)

            // Wave chart
            Chart {
                ForEach(wavePoints) { pt in
                    LineMark(x: .value("t", pt.x), y: .value("x", pt.y))
                        .foregroundStyle(Color.appPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                }
                let tMod = time.truncatingRemainder(dividingBy: 3.0)
                PointMark(x: .value("t", tMod), y: .value("x", amplitude * sin(omega * tMod)))
                    .foregroundStyle(.red)
                    .symbolSize(60)
                RuleMark(y: .value("eq", 0))
                    .foregroundStyle(.secondary.opacity(0.2))
            }
            .chartYScale(domain: -5...5)
            .chartXScale(domain: 0...3)
            .chartXAxisLabel("Time (s)")
            .chartYAxisLabel("x (m)")
            .frame(height: 120)
            .padding(.horizontal, 8)

            HStack(spacing: 12) {
                InfoChip(label: "Position", value: "\(String(format: "%.2f", currentX)) m", color: .red)
                InfoChip(label: "Period", value: "\(String(format: "%.2f", period)) s", color: .blue)
                InfoChip(label: "ω", value: "\(String(format: "%.1f", omega)) rad/s", color: .orange)
            }
            .padding(.horizontal, 8)

            PlaybackControlView(isPlaying: $isPlaying, speed: .constant(1.0)) {
                time = 0; isPlaying = false
            }

            VStack(spacing: 4) {
                ParameterSliderView(label: "Amplitude", symbol: "A", value: $amplitude, range: 0.5...5, step: 0.5, unit: "m", color: .red)
                ParameterSliderView(label: "Frequency", symbol: "f", value: $frequency, range: 0.2...3, step: 0.1, unit: "Hz", color: .blue)
            }
            .padding(.horizontal, 8)
        }
        .onReceive(timer) { _ in
            guard isPlaying, !reduceMotion else { return }
            time += 0.02
        }
    }
}

// MARK: - Pendulum  T = 2π√(L/g)

/// Animated simple pendulum
struct PendulumView: View {
    @State private var length: Double = 2.0
    @State private var gravity: Double = 9.81
    @State private var isPlaying = true
    @State private var angle: Double = 0.5   // initial angle in rad
    @State private var angularVelocity: Double = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    private var period: Double { 2 * .pi * sqrt(length / gravity) }

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let pivotX = w / 2
                let pivotY: CGFloat = 20
                let ropeLen = min(h - 60, CGFloat(length / 4.0) * 100)
                let bobX = pivotX + ropeLen * CGFloat(sin(angle))
                let bobY = pivotY + ropeLen * CGFloat(cos(angle))

                Canvas { ctx, _ in
                    // Pivot
                    ctx.fill(Path(ellipseIn: CGRect(x: pivotX - 4, y: pivotY - 4, width: 8, height: 8)),
                             with: .color(.secondary))

                    // Rope
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: pivotX, y: pivotY))
                        p.addLine(to: CGPoint(x: bobX, y: bobY))
                    }, with: .color(.primary.opacity(0.6)), lineWidth: 2)

                    // Vertical dashed
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: pivotX, y: pivotY))
                        p.addLine(to: CGPoint(x: pivotX, y: pivotY + ropeLen + 10))
                    }, with: .color(.secondary.opacity(0.2)), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

                    // Bob
                    let r: CGFloat = 20
                    ctx.fill(Path(ellipseIn: CGRect(x: bobX - r, y: bobY - r, width: 2 * r, height: 2 * r)),
                             with: .color(.appPrimary.opacity(0.85)))
                    ctx.draw(Text("m").font(.system(size: 12, weight: .bold)).foregroundStyle(.white),
                             at: CGPoint(x: bobX, y: bobY))

                    // Arc showing angle
                    if abs(angle) > 0.05 {
                        let arcR: CGFloat = 30
                        let startAngle = Angle(degrees: 90)
                        let endAngle = Angle(radians: .pi / 2 - angle)
                        ctx.stroke(Path { p in
                            p.addArc(center: CGPoint(x: pivotX, y: pivotY), radius: arcR,
                                     startAngle: startAngle, endAngle: endAngle,
                                     clockwise: angle > 0)
                        }, with: .color(.orange), lineWidth: 1.5)
                        ctx.draw(Text("θ").font(.system(size: 11, weight: .bold, design: .serif)).foregroundStyle(.orange),
                                 at: CGPoint(x: pivotX + (angle > 0 ? 20 : -20), y: pivotY + 45))
                    }
                }
            }
            .frame(height: 220)

            HStack(spacing: 12) {
                InfoChip(label: "Period", value: "\(String(format: "%.2f", period)) s", color: .appPrimary)
                InfoChip(label: "Angle", value: "\(String(format: "%.1f", angle * 180 / .pi))°", color: .orange)
                InfoChip(label: "Length", value: "\(String(format: "%.1f", length)) m", color: .green)
            }
            .padding(.horizontal, 8)

            PlaybackControlView(isPlaying: $isPlaying, speed: .constant(1.0)) {
                angle = 0.5; angularVelocity = 0; isPlaying = false
            }

            VStack(spacing: 4) {
                ParameterSliderView(label: "Length", symbol: "L", value: $length, range: 0.5...5, step: 0.1, unit: "m", color: .green)
                ParameterSliderView(label: "Gravity", symbol: "g", value: $gravity, range: 1...20, step: 0.5, unit: "m/s²", color: .orange)
            }
            .padding(.horizontal, 8)
        }
        .onReceive(timer) { _ in
            guard isPlaying, !reduceMotion else { return }
            let dt = 0.016
            let angularAccel = -(gravity / length) * sin(angle)
            angularVelocity += angularAccel * dt
            angularVelocity *= 0.999 // tiny damping
            angle += angularVelocity * dt
        }
    }
}

// MARK: - Newton's Second Law  F = ma

/// Force-acceleration vector diagram with mass slider
struct NewtonsSecondLawView: View {
    @State private var force: Double = 10.0
    @State private var mass: Double = 2.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var acceleration: Double { mass > 0 ? force / mass : 0 }

    private var points: [GraphPoint] {
        stride(from: 0.0, through: 20.0, by: 0.2).map { f in
            GraphPoint(x: f, y: mass > 0 ? f / mass : 0)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Vector diagram
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w * 0.35
                let cy = h / 2
                let blockW: CGFloat = CGFloat(mass) * 12 + 30
                let blockH: CGFloat = CGFloat(mass) * 8 + 20

                Canvas { ctx, _ in
                    // Ground
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: 0, y: cy + blockH / 2))
                        p.addLine(to: CGPoint(x: w, y: cy + blockH / 2))
                    }, with: .color(.secondary.opacity(0.3)), lineWidth: 1)

                    // Block
                    let blockRect = CGRect(x: cx - blockW / 2, y: cy - blockH / 2, width: blockW, height: blockH)
                    ctx.fill(Path(roundedRect: blockRect, cornerRadius: 4),
                             with: .color(.blue.opacity(0.7)))
                    ctx.draw(Text("\(String(format: "%.0f", mass)) kg")
                        .font(.system(size: 12, weight: .bold)).foregroundStyle(.white),
                             at: CGPoint(x: cx, y: cy))

                    // Force arrow
                    let arrowLen = min(CGFloat(force) * 6, w * 0.4)
                    let arrowY = cy
                    let arrowStart = cx + blockW / 2
                    let arrowEnd = arrowStart + arrowLen
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: arrowStart, y: arrowY))
                        p.addLine(to: CGPoint(x: arrowEnd, y: arrowY))
                        p.addLine(to: CGPoint(x: arrowEnd - 10, y: arrowY - 6))
                        p.move(to: CGPoint(x: arrowEnd, y: arrowY))
                        p.addLine(to: CGPoint(x: arrowEnd - 10, y: arrowY + 6))
                    }, with: .color(.red), lineWidth: 3)
                    ctx.draw(Text("F = \(String(format: "%.0f", force)) N")
                        .font(.system(size: 11, weight: .bold)).foregroundStyle(.red),
                             at: CGPoint(x: (arrowStart + arrowEnd) / 2, y: arrowY - 16))

                    // Acceleration arrow
                    let aLen = min(CGFloat(acceleration) * 10, w * 0.35)
                    let aY = cy + blockH / 2 + 24
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: cx, y: aY))
                        p.addLine(to: CGPoint(x: cx + aLen, y: aY))
                        p.addLine(to: CGPoint(x: cx + aLen - 8, y: aY - 5))
                        p.move(to: CGPoint(x: cx + aLen, y: aY))
                        p.addLine(to: CGPoint(x: cx + aLen - 8, y: aY + 5))
                    }, with: .color(.green), lineWidth: 2)
                    ctx.draw(Text("a = \(String(format: "%.1f", acceleration)) m/s²")
                        .font(.system(size: 10, weight: .bold)).foregroundStyle(.green),
                             at: CGPoint(x: cx + aLen / 2, y: aY - 12))
                }
            }
            .frame(height: 160)

            // F-a graph
            Chart {
                ForEach(points) { pt in
                    LineMark(x: .value("F", pt.x), y: .value("a", pt.y))
                        .foregroundStyle(Color.appPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                }
                PointMark(x: .value("F", force), y: .value("a", acceleration))
                    .foregroundStyle(.red)
                    .symbolSize(70)
            }
            .chartXScale(domain: 0...20)
            .chartYScale(domain: 0...max(acceleration * 1.3, 5))
            .chartXAxisLabel("Force (N)")
            .chartYAxisLabel("Acceleration (m/s²)")
            .frame(height: 140)
            .padding(.horizontal, 8)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: force)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: mass)

            HStack(spacing: 12) {
                InfoChip(label: "Force", value: "\(String(format: "%.0f", force)) N", color: .red)
                InfoChip(label: "Mass", value: "\(String(format: "%.1f", mass)) kg", color: .blue)
                InfoChip(label: "Accel", value: "\(String(format: "%.1f", acceleration)) m/s²", color: .green)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 4) {
                ParameterSliderView(label: "Applied force", symbol: "F", value: $force, range: 1...20, step: 0.5, unit: "N", color: .red)
                ParameterSliderView(label: "Mass", symbol: "m", value: $mass, range: 0.5...10, step: 0.5, unit: "kg", color: .blue)
            }
            .padding(.horizontal, 8)
        }
    }
}

// MARK: - Coulomb's Law  F = kq₁q₂/r²

/// Force vs distance graph for two charges
struct CoulombsLawView: View {
    @State private var q1: Double = 2.0   // μC
    @State private var q2: Double = 3.0   // μC
    @State private var distance: Double = 0.5  // m
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let k = 8.99e9

    private var forceN: Double {
        let qq = (q1 * 1e-6) * (q2 * 1e-6)
        return distance > 0 ? k * abs(qq) / (distance * distance) : 0
    }

    private var curvePoints: [GraphPoint] {
        stride(from: 0.1, through: 3.0, by: 0.02).map { r in
            let qq = (q1 * 1e-6) * (q2 * 1e-6)
            let f = k * abs(qq) / (r * r)
            return GraphPoint(x: r, y: min(f, 5))
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Charge diagram
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cy = h / 2
                let margin: CGFloat = 60
                let maxDist = w - 2 * margin
                let sep = CGFloat(distance / 3.0) * maxDist
                let x1 = w / 2 - sep / 2
                let x2 = w / 2 + sep / 2

                Canvas { ctx, _ in
                    // Charges
                    let r: CGFloat = 24
                    ctx.fill(Path(ellipseIn: CGRect(x: x1 - r, y: cy - r, width: 2 * r, height: 2 * r)),
                             with: .color(.red.opacity(0.8)))
                    ctx.draw(Text("+q₁").font(.system(size: 11, weight: .bold)).foregroundStyle(.white),
                             at: CGPoint(x: x1, y: cy))

                    ctx.fill(Path(ellipseIn: CGRect(x: x2 - r, y: cy - r, width: 2 * r, height: 2 * r)),
                             with: .color(.blue.opacity(0.8)))
                    ctx.draw(Text("+q₂").font(.system(size: 11, weight: .bold)).foregroundStyle(.white),
                             at: CGPoint(x: x2, y: cy))

                    // Force arrows (repulsive)
                    let arrowLen: CGFloat = min(CGFloat(forceN) * 30, 60)
                    // Arrow from q1 pointing left
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: x1 - r, y: cy))
                        p.addLine(to: CGPoint(x: x1 - r - arrowLen, y: cy))
                        p.addLine(to: CGPoint(x: x1 - r - arrowLen + 8, y: cy - 5))
                        p.move(to: CGPoint(x: x1 - r - arrowLen, y: cy))
                        p.addLine(to: CGPoint(x: x1 - r - arrowLen + 8, y: cy + 5))
                    }, with: .color(.orange), lineWidth: 2)

                    // Arrow from q2 pointing right
                    ctx.stroke(Path { p in
                        p.move(to: CGPoint(x: x2 + r, y: cy))
                        p.addLine(to: CGPoint(x: x2 + r + arrowLen, y: cy))
                        p.addLine(to: CGPoint(x: x2 + r + arrowLen - 8, y: cy - 5))
                        p.move(to: CGPoint(x: x2 + r + arrowLen, y: cy))
                        p.addLine(to: CGPoint(x: x2 + r + arrowLen - 8, y: cy + 5))
                    }, with: .color(.orange), lineWidth: 2)

                    // Distance label
                    ctx.draw(Text("\(String(format: "%.2f", distance)) m")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced)).foregroundStyle(.secondary),
                             at: CGPoint(x: w / 2, y: cy + r + 16))
                }
            }
            .frame(height: 120)

            // F vs r graph
            Chart {
                ForEach(curvePoints) { pt in
                    LineMark(x: .value("r", pt.x), y: .value("F", pt.y))
                        .foregroundStyle(Color.appPrimary.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                }
                PointMark(x: .value("r", distance), y: .value("F", min(forceN, 5)))
                    .foregroundStyle(.red)
                    .symbolSize(70)
            }
            .chartXScale(domain: 0.1...3)
            .chartYScale(domain: 0...5)
            .chartXAxisLabel("Distance r (m)")
            .chartYAxisLabel("Force F (N)")
            .frame(height: 140)
            .padding(.horizontal, 8)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: q1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: q2)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.15), value: distance)

            HStack(spacing: 12) {
                InfoChip(label: "Force", value: forceN < 0.01 ? String(format: "%.2e", forceN) : String(format: "%.3f N", forceN), color: .orange)
                InfoChip(label: "q₁", value: "\(String(format: "%.1f", q1)) μC", color: .red)
                InfoChip(label: "q₂", value: "\(String(format: "%.1f", q2)) μC", color: .blue)
            }
            .padding(.horizontal, 8)

            VStack(spacing: 4) {
                ParameterSliderView(label: "Charge 1", symbol: "q₁", value: $q1, range: 0.5...10, step: 0.5, unit: "μC", color: .red)
                ParameterSliderView(label: "Charge 2", symbol: "q₂", value: $q2, range: 0.5...10, step: 0.5, unit: "μC", color: .blue)
                ParameterSliderView(label: "Distance", symbol: "r", value: $distance, range: 0.1...3, step: 0.05, unit: "m", color: .green)
            }
            .padding(.horizontal, 8)
        }
    }
}

#Preview("Ohm's Law") { ScrollView { OhmsLawView().padding() } }
#Preview("Hooke's Law") { ScrollView { HookesLawView().padding() } }
#Preview("SHM") { ScrollView { SimpleHarmonicMotionView().padding() } }
#Preview("Pendulum") { ScrollView { PendulumView().padding() } }
#Preview("Newton F=ma") { ScrollView { NewtonsSecondLawView().padding() } }
#Preview("Coulomb") { ScrollView { CoulombsLawView().padding() } }
