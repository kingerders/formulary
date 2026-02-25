import Foundation

/// Type of interactive visualization
enum VizType: String, Codable, CaseIterable {
    case parameterGraph
    case geometric
    case process
    case vectorField

    var displayName: String {
        switch self {
        case .parameterGraph: return "Interactive Graph"
        case .geometric: return "Geometry"
        case .process: return "Process Animation"
        case .vectorField: return "Vector Field"
        }
    }

    var icon: String {
        switch self {
        case .parameterGraph: return "chart.xyaxis.line"
        case .geometric: return "triangle"
        case .process: return "arrow.triangle.branch"
        case .vectorField: return "wind"
        }
    }
}

/// Registry entry linking a formula title to its visualization
struct VisualizationEntry: Identifiable {
    let id = UUID()
    let formulaTitle: String        // Match against Formula.title
    let type: VizType
    let viewIdentifier: String      // Maps to a concrete SwiftUI view
    let title: String
    let isPremium: Bool

    init(_ formulaTitle: String, type: VizType, view: String, title: String, isPremium: Bool = false) {
        self.formulaTitle = formulaTitle
        self.type = type
        self.viewIdentifier = view
        self.title = title
        self.isPremium = isPremium
    }
}

/// Central registry of all available visualizations
struct VisualizationRegistry {
    static let entries: [VisualizationEntry] = [
        // ── Mathematics ──────────────────────────────────

        // Quadratic formula
        VisualizationEntry("Quadratic Formula", type: .parameterGraph, view: "QuadraticGraphView", title: "Interactive Parabola"),
        VisualizationEntry("Quadratic Equation", type: .parameterGraph, view: "QuadraticGraphView", title: "Interactive Parabola"),

        // Sine / Cosine
        VisualizationEntry("Sine Function", type: .geometric, view: "SineCosineView", title: "Unit Circle → Wave"),
        VisualizationEntry("Cosine Function", type: .geometric, view: "SineCosineView", title: "Unit Circle → Wave"),
        VisualizationEntry("Sine Rule", type: .geometric, view: "SineCosineView", title: "Unit Circle → Wave"),
        VisualizationEntry("Law of Sines", type: .geometric, view: "SineCosineView", title: "Unit Circle → Wave"),
        VisualizationEntry("Law of Cosines", type: .geometric, view: "SineCosineView", title: "Unit Circle → Wave"),
        VisualizationEntry("Trigonometric Identities", type: .geometric, view: "SineCosineView", title: "Unit Circle → Wave"),
        VisualizationEntry("Unit Circle Values", type: .geometric, view: "SineCosineView", title: "Unit Circle → Wave"),
        VisualizationEntry("Pythagorean Identity", type: .geometric, view: "SineCosineView", title: "Unit Circle → Wave"),

        // Normal distribution
        VisualizationEntry("Normal Distribution", type: .parameterGraph, view: "NormalDistributionView", title: "Bell Curve Explorer"),
        VisualizationEntry("Gaussian Distribution", type: .parameterGraph, view: "NormalDistributionView", title: "Bell Curve Explorer"),
        VisualizationEntry("Standard Normal Distribution", type: .parameterGraph, view: "NormalDistributionView", title: "Bell Curve Explorer"),
        VisualizationEntry("Multivariate Normal Distribution", type: .parameterGraph, view: "NormalDistributionView", title: "Bell Curve Explorer"),
        VisualizationEntry("Gaussian Dispersion", type: .parameterGraph, view: "NormalDistributionView", title: "Bell Curve Explorer"),
        VisualizationEntry("Normal Equation", type: .parameterGraph, view: "NormalDistributionView", title: "Bell Curve Explorer"),

        // Pythagorean theorem
        VisualizationEntry("Pythagorean Theorem", type: .geometric, view: "PythagoreanView", title: "Visual Proof"),
        VisualizationEntry("Pythagoras' Theorem", type: .geometric, view: "PythagoreanView", title: "Visual Proof"),

        // Circle
        VisualizationEntry("Circle", type: .geometric, view: "CircleAreaView", title: "Interactive Circle"),
        VisualizationEntry("Circle Area", type: .geometric, view: "CircleAreaView", title: "Interactive Circle"),
        VisualizationEntry("Apollonius Circle", type: .geometric, view: "CircleAreaView", title: "Interactive Circle"),
        VisualizationEntry("Osculating Circle", type: .geometric, view: "CircleAreaView", title: "Interactive Circle"),
        VisualizationEntry("Nine-Point Circle", type: .geometric, view: "CircleAreaView", title: "Interactive Circle"),

        // Exponential growth / decay
        VisualizationEntry("Exponential Growth", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("Exponential Distribution", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("Half-Life", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("Half-Life (1st order)", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("Half-Life (drug)", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("Radioactive Decay", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("First-Order Decay", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("First-Order Decay (IPCC)", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("Decay Constant", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("Alpha, Beta, Gamma Decay", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("Decay Chains & Secular Equilibrium", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),
        VisualizationEntry("Logarithmic Decrement", type: .parameterGraph, view: "ExponentialGrowthView", title: "Growth & Decay"),

        // ── Classical Mechanics ──────────────────────────

        // Projectile motion
        VisualizationEntry("Projectile Motion", type: .parameterGraph, view: "ProjectileMotionView", title: "Trajectory Simulator"),
        VisualizationEntry("Range of Projectile", type: .parameterGraph, view: "ProjectileMotionView", title: "Trajectory Simulator"),
        VisualizationEntry("Projectile Range Formula", type: .parameterGraph, view: "ProjectileMotionView", title: "Trajectory Simulator"),

        // Newton's Second Law F = ma
        VisualizationEntry("Newton's 2nd Law", type: .parameterGraph, view: "NewtonsSecondLawView", title: "F = ma Explorer"),
        VisualizationEntry("Newton's 1st Law (Inertia)", type: .parameterGraph, view: "NewtonsSecondLawView", title: "F = ma Explorer"),
        VisualizationEntry("Newton's 3rd Law (Action-Reaction)", type: .parameterGraph, view: "NewtonsSecondLawView", title: "F = ma Explorer"),
        VisualizationEntry("Newton's 2nd for Rotation", type: .parameterGraph, view: "NewtonsSecondLawView", title: "F = ma Explorer"),
        VisualizationEntry("Force on Current-Carrying Wire", type: .parameterGraph, view: "NewtonsSecondLawView", title: "F = ma Explorer"),

        // Hooke's Law F = kx
        VisualizationEntry("Hooke's Law", type: .process, view: "HookesLawView", title: "Spring Force"),
        VisualizationEntry("Generalized Hooke's Law (3D)", type: .process, view: "HookesLawView", title: "Spring Force"),
        VisualizationEntry("Period of Spring", type: .process, view: "HookesLawView", title: "Spring Force"),
        VisualizationEntry("Spring Design", type: .process, view: "HookesLawView", title: "Spring Force"),
        VisualizationEntry("Elastic Potential Energy", type: .process, view: "HookesLawView", title: "Spring Force"),

        // Simple Harmonic Motion
        VisualizationEntry("Simple Harmonic Motion", type: .process, view: "SimpleHarmonicMotionView", title: "SHM Oscillator"),
        VisualizationEntry("Forced Vibration", type: .process, view: "SimpleHarmonicMotionView", title: "SHM Oscillator"),
        VisualizationEntry("Harmonic Oscillator (quantum)", type: .process, view: "SimpleHarmonicMotionView", title: "SHM Oscillator"),
        VisualizationEntry("Standing Waves & Harmonics (strings, pipes)", type: .process, view: "SimpleHarmonicMotionView", title: "SHM Oscillator"),

        // Pendulum
        VisualizationEntry("Period of Pendulum", type: .process, view: "PendulumView", title: "Pendulum Swing"),
        VisualizationEntry("Physical Pendulum", type: .process, view: "PendulumView", title: "Pendulum Swing"),
        VisualizationEntry("Torsional Pendulum", type: .process, view: "PendulumView", title: "Pendulum Swing"),

        // Coulomb's Law
        VisualizationEntry("Coulomb's Law", type: .parameterGraph, view: "CoulombsLawView", title: "Electric Force"),
        VisualizationEntry("Coulomb", type: .parameterGraph, view: "CoulombsLawView", title: "Electric Force"),
        VisualizationEntry("Electric Potential", type: .parameterGraph, view: "CoulombsLawView", title: "Electric Force"),

        // ── Electricity ──────────────────────────────────

        // Ohm's Law V = IR
        VisualizationEntry("Ohm's Law", type: .parameterGraph, view: "OhmsLawView", title: "V–I Curve"),
        VisualizationEntry("Resistors in Series", type: .parameterGraph, view: "OhmsLawView", title: "V–I Curve"),
        VisualizationEntry("Resistors in Parallel", type: .parameterGraph, view: "OhmsLawView", title: "V–I Curve"),
        VisualizationEntry("Impedance", type: .parameterGraph, view: "OhmsLawView", title: "V–I Curve"),
        VisualizationEntry("Capacitor Impedance", type: .parameterGraph, view: "OhmsLawView", title: "V–I Curve"),
        VisualizationEntry("Inductor Impedance", type: .parameterGraph, view: "OhmsLawView", title: "V–I Curve"),
        VisualizationEntry("Maximum Power Transfer", type: .parameterGraph, view: "OhmsLawView", title: "V–I Curve"),

        // ── Waves & Optics ───────────────────────────────

        // Snell's Law
        VisualizationEntry("Snell's Law", type: .geometric, view: "SnellsLawView", title: "Light Refraction"),
        VisualizationEntry("Thin Lens Equation", type: .geometric, view: "SnellsLawView", title: "Light Refraction"),
        VisualizationEntry("Lensmaker's Equation", type: .geometric, view: "SnellsLawView", title: "Light Refraction"),
        VisualizationEntry("Diffraction Grating", type: .geometric, view: "SnellsLawView", title: "Light Refraction"),
        VisualizationEntry("Abbe Number (dispersive power)", type: .geometric, view: "SnellsLawView", title: "Light Refraction"),

        // Doppler Effect
        VisualizationEntry("Doppler Effect", type: .process, view: "DopplerEffectView", title: "Doppler Waves"),
        VisualizationEntry("Doppler Ultrasound", type: .process, view: "DopplerEffectView", title: "Doppler Waves"),
        VisualizationEntry("Radial Velocity (Doppler)", type: .process, view: "DopplerEffectView", title: "Doppler Waves"),

        // Wave Superposition
        VisualizationEntry("Superposition of Waves", type: .process, view: "WaveSuperpositionView", title: "Wave Interference"),
        VisualizationEntry("Wave Equation", type: .process, view: "WaveSuperpositionView", title: "Wave Interference"),
        VisualizationEntry("Electromagnetic Wave", type: .process, view: "WaveSuperpositionView", title: "Wave Interference"),
        VisualizationEntry("Group Velocity", type: .process, view: "WaveSuperpositionView", title: "Wave Interference"),
        VisualizationEntry("Phase Velocity", type: .process, view: "WaveSuperpositionView", title: "Wave Interference"),
        VisualizationEntry("Group Velocity vs Phase Velocity", type: .process, view: "WaveSuperpositionView", title: "Wave Interference"),
        VisualizationEntry("Surface Waves", type: .process, view: "WaveSuperpositionView", title: "Wave Interference"),
        VisualizationEntry("Gravitational Waves", type: .process, view: "WaveSuperpositionView", title: "Wave Interference"),

        // ── Thermodynamics ───────────────────────────────

        // Ideal Gas Law PV = nRT
        VisualizationEntry("Ideal Gas Law", type: .parameterGraph, view: "IdealGasLawView", title: "PV Diagram"),
        VisualizationEntry("Ideal Gas Law (atmosphere)", type: .parameterGraph, view: "IdealGasLawView", title: "PV Diagram"),
        VisualizationEntry("Ideal Gas Law (dry air)", type: .parameterGraph, view: "IdealGasLawView", title: "PV Diagram"),
        VisualizationEntry("Boyle's Law", type: .parameterGraph, view: "IdealGasLawView", title: "PV Diagram"),
        VisualizationEntry("Charles's Law", type: .parameterGraph, view: "IdealGasLawView", title: "PV Diagram"),
        VisualizationEntry("Dalton's Law of Partial Pressures", type: .parameterGraph, view: "IdealGasLawView", title: "PV Diagram"),
        VisualizationEntry("Carnot Efficiency", type: .parameterGraph, view: "IdealGasLawView", title: "PV Diagram"),
        VisualizationEntry("Kinetic Theory", type: .parameterGraph, view: "IdealGasLawView", title: "PV Diagram"),
    ]

    /// Find a visualization entry matching a formula title (case-insensitive contains)
    static func visualization(for formulaTitle: String) -> VisualizationEntry? {
        let lower = formulaTitle.lowercased()
        return entries.first { lower.contains($0.formulaTitle.lowercased()) || $0.formulaTitle.lowercased().contains(lower) }
    }
}
