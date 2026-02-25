import SwiftUI

/// Routes a VisualizationEntry.viewIdentifier to its concrete SwiftUI view
struct VisualizationRouter: View {
    let entry: VisualizationEntry

    var body: some View {
        switch entry.viewIdentifier {
        // Math
        case "QuadraticGraphView":
            QuadraticGraphView()
        case "SineCosineView":
            SineCosineView()
        case "NormalDistributionView":
            NormalDistributionView()
        case "PythagoreanView":
            PythagoreanView()
        case "CircleAreaView":
            CircleAreaView()
        case "ExponentialGrowthView":
            ExponentialGrowthView()

        // Physics — mechanics
        case "ProjectileMotionView":
            ProjectileMotionView()
        case "NewtonsSecondLawView":
            NewtonsSecondLawView()
        case "HookesLawView":
            HookesLawView()
        case "SimpleHarmonicMotionView":
            SimpleHarmonicMotionView()
        case "PendulumView":
            PendulumView()
        case "CoulombsLawView":
            CoulombsLawView()

        // Electricity
        case "OhmsLawView":
            OhmsLawView()

        // Waves & optics
        case "SnellsLawView":
            SnellsLawView()
        case "DopplerEffectView":
            DopplerEffectView()
        case "WaveSuperpositionView":
            WaveSuperpositionView()

        // Thermodynamics
        case "IdealGasLawView":
            IdealGasLawView()

        default:
            ContentUnavailableView("Coming Soon", systemImage: "hammer.fill", description: Text("This visualization is being built."))
        }
    }
}
