import SwiftUI

/// Quicksand custom font helpers
extension Font {
    /// Quicksand with the given size and weight
    static func quicksand(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .light, .ultraLight, .thin:
            name = "Quicksand-Light"
        case .regular:
            name = "Quicksand-Regular"
        case .medium:
            name = "Quicksand-Medium"
        case .semibold:
            name = "Quicksand-SemiBold"
        case .bold, .heavy, .black:
            name = "Quicksand-Bold"
        default:
            name = "Quicksand-Regular"
        }
        return .custom(name, size: size)
    }

    // MARK: - Semantic shortcuts (matching Dynamic Type categories)

    /// Large title — 34pt bold
    static var qLargeTitle: Font { .quicksand(34, weight: .bold) }
    /// Title — 28pt bold
    static var qTitle: Font { .quicksand(28, weight: .bold) }
    /// Title 2 — 22pt bold
    static var qTitle2: Font { .quicksand(22, weight: .bold) }
    /// Title 3 — 20pt semibold
    static var qTitle3: Font { .quicksand(20, weight: .semibold) }
    /// Headline — 17pt semibold
    static var qHeadline: Font { .quicksand(17, weight: .semibold) }
    /// Body — 17pt regular
    static var qBody: Font { .quicksand(17, weight: .regular) }
    /// Callout — 16pt medium
    static var qCallout: Font { .quicksand(16, weight: .medium) }
    /// Subheadline — 15pt medium
    static var qSubheadline: Font { .quicksand(15, weight: .medium) }
    /// Footnote — 13pt medium
    static var qFootnote: Font { .quicksand(13, weight: .medium) }
    /// Caption — 12pt medium
    static var qCaption: Font { .quicksand(12, weight: .medium) }
    /// Caption 2 — 11pt medium
    static var qCaption2: Font { .quicksand(11, weight: .medium) }
}
