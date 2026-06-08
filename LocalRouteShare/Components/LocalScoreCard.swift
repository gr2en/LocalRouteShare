import SwiftUI

struct LocalScoreCard: View {
    var profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Local Score")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.textSecondary)

                    Text("\(profile.localScore)")
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.primaryPurple.opacity(0.12))
                        .frame(width: 54, height: 54)
                    Image(systemName: "sparkles")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.primaryPurple)
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                Text("This week +\(profile.weeklyIncrease) pts")
                    .font(.caption.weight(.bold))
                Text("- \(profile.level)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
            }
            .foregroundStyle(Color(hex: "#10B981"))
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.borderGray.opacity(0.8), lineWidth: 1)
        )
    }
}
