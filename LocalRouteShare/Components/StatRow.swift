import SwiftUI

struct StatRow: View {
    var icon: String
    var title: String
    var value: String
    var tint: Color = .primaryPurple
    var showsChevron = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(tint.opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(tint)
            }

            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.textPrimary)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(.vertical, 6)
    }
}
