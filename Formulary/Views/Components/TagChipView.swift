import SwiftUI

/// A small chip view for displaying tags
struct TagChipView: View {
    let tag: String

    var body: some View {
        Text(tag)
            .font(.qCaption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.appPrimary.opacity(0.1))
            .foregroundStyle(Color.appPrimary)
            .clipShape(Capsule())
    }
}

/// A horizontal scrollable row of tag chips
struct TagsRow: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    TagChipView(tag: tag)
                }
            }
        }
    }
}

#Preview {
    TagsRow(tags: ["quadratic", "roots", "polynomial", "algebra"])
        .padding()
}
