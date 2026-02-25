import Foundation
import SwiftData

/// User-created note attached to a formula
@Model
final class UserNote {
    @Attribute(.unique) var id: UUID
    var noteText: String
    var createdAt: Date

    var formula: Formula?

    init(
        id: UUID = UUID(),
        noteText: String,
        createdAt: Date = .now,
        formula: Formula? = nil
    ) {
        self.id = id
        self.noteText = noteText
        self.createdAt = createdAt
        self.formula = formula
    }
}
