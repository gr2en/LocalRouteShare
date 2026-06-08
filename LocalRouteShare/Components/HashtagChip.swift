import SwiftUI

struct HashtagChip: View {
    var title: String
    var isSelected: Bool = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title.hasPrefix("#") ? title : "#\(title)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : Color.textSecondary)
                .lineLimit(1)
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(isSelected ? Color.primaryPurple : Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.primaryPurple : Color.borderGray, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
