import SwiftUI

/// Badge showing the difficulty level of a formula
struct LevelBadgeView: View {
    let level: FormulaLevel

    private var badgeColor: Color {
        switch level {
        case .highSchool: return .levelHighSchool
        case .undergraduate: return .levelUndergrad
        case .graduate: return .levelGraduate
        case .professional: return .levelProfessional
        }
    }

    var body: some View {
        Text(level.shortName)
            .font(.qCaption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(badgeColor.opacity(0.15))
            .foregroundStyle(badgeColor)
            .clipShape(Capsule())
    }
}

/// Larger badge with full level name
struct LevelBadgeFullView: View {
    let level: FormulaLevel

    private var badgeColor: Color {
        switch level {
        case .highSchool: return .levelHighSchool
        case .undergraduate: return .levelUndergrad
        case .graduate: return .levelGraduate
        case .professional: return .levelProfessional
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(badgeColor)
                .frame(width: 6, height: 6)
            Text(level.displayName)
                .font(.qCaption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(badgeColor.opacity(0.1))
        .foregroundStyle(badgeColor)
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(FormulaLevel.allCases, id: \.self) { level in
            HStack {
                LevelBadgeView(level: level)
                LevelBadgeFullView(level: level)
            }
        }
    }
    .padding()
}
