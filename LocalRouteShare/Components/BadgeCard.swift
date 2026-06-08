import SwiftUI

struct BadgeCard: View {
    var badge: Badge

    var body: some View {
        VStack(spacing: 9) {
            Text(badge.emoji)
                .font(.system(size: 30))
                .frame(width: 48, height: 48)
                .background(badge.isUnlocked ? Color.primaryPurple.opacity(0.10) : Color.lightGray)
                .clipShape(Circle())
                .saturation(badge.isUnlocked ? 1 : 0)
                .opacity(badge.isUnlocked ? 1 : 0.45)

            Text(badge.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(badge.isUnlocked ? Color.textPrimary : Color.textSecondary)
                .lineLimit(1)

            Text(badge.subtitle)
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }
}
