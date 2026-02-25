import Foundation
import SwiftData

/// Difficulty level of a formula
enum FormulaLevel: String, Codable, CaseIterable {
    case highSchool = "highSchool"
    case undergraduate = "undergraduate"
    case graduate = "graduate"
    case professional = "professional"

    var displayName: String {
        switch self {
        case .highSchool: return "High School"
        case .undergraduate: return "Undergraduate"
        case .graduate: return "Graduate"
        case .professional: return "Professional"
        }
    }

    var shortName: String {
        switch self {
        case .highSchool: return "HS"
        case .undergraduate: return "UG"
        case .graduate: return "Grad"
        case .professional: return "Pro"
        }
    }

    var color: String {
        switch self {
        case .highSchool: return "levelHighSchool"
        case .undergraduate: return "levelUndergrad"
        case .graduate: return "levelGraduate"
        case .professional: return "levelProfessional"
        }
    }

    var sortIndex: Int {
        switch self {
        case .highSchool: return 0
        case .undergraduate: return 1
        case .graduate: return 2
        case .professional: return 3
        }
    }
}

/// Represents a single scientific formula
@Model
final class Formula {
    @Attribute(.unique) var id: UUID
    var title: String
    var latex: String
    var formulaDescription: String
    var whatIsItFor: String = ""
    var variables: String
    var order: Int
    var level: FormulaLevel
    var isFavorite: Bool
    var isPremium: Bool
    var tags: [String]
    /// Optional image name for visual diagrams (e.g. "physics_projectile_motion")
    var imageName: String = ""
    /// Titles of related formulas for cross-linking
    var relatedFormulaTitles: [String] = []

    var subcategory: Subcategory?

    @Relationship(deleteRule: .cascade, inverse: \UserNote.formula)
    var notes: [UserNote] = []

    init(
        id: UUID = UUID(),
        title: String,
        latex: String,
        formulaDescription: String = "",
        whatIsItFor: String = "",
        variables: String = "",
        order: Int = 0,
        level: FormulaLevel = .undergraduate,
        isFavorite: Bool = false,
        isPremium: Bool = false,
        tags: [String] = [],
        imageName: String = "",
        relatedFormulaTitles: [String] = [],
        subcategory: Subcategory? = nil
    ) {
        self.id = id
        self.title = title
        self.latex = latex
        self.formulaDescription = formulaDescription
        self.whatIsItFor = whatIsItFor
        self.variables = variables
        self.order = order
        self.level = level
        self.isFavorite = isFavorite
        self.isPremium = isPremium
        self.tags = tags
        self.imageName = imageName
        self.relatedFormulaTitles = relatedFormulaTitles
        self.subcategory = subcategory
    }
}
