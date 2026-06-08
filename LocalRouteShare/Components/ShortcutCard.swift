import SwiftUI

struct ShortcutCard: View {
    var shortcut: Shortcut
    var primaryActionTitle: String = "Start Guidance"
    var primaryActionSystemImage: String = "arrow.triangle.turn.up.right.diamond.fill"
    var onStartGuide: () -> Void = {}
    var onToggleSave: () -> Void
    var onReport: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.primaryPurple.opacity(0.16), Color.primaryBlue.opacity(0.14)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                    Image(systemName: "map.fill")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.primaryPurple)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(shortcut.title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(2)

                    Text("By \(shortcut.author)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer(minLength: 8)

                Button(action: onReport) {
                    Image(systemName: "exclamationmark.bubble")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 34, height: 34)
                        .background(Color.backgroundGray)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Text(shortcut.routeDescription)
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)
                .lineSpacing(3)

            HStack(spacing: 10) {
                MetricPill(icon: "clock.fill", value: shortcut.estimatedTime)
                MetricPill(icon: "location.fill", value: shortcut.distance)
                MetricPill(icon: "star.fill", value: String(format: "%.1f (%d)", shortcut.rating, shortcut.ratingCount))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(shortcut.tags, id: \.self) { tag in
                        HashtagChip(title: tag)
                    }
                }
            }

            HStack(spacing: 10) {
                Button(action: onStartGuide) {
                    Label(primaryActionTitle, systemImage: primaryActionSystemImage)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.buttonBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)

                Button(action: onToggleSave) {
                    HStack(spacing: 6) {
                        Image(systemName: shortcut.isSaved ? "bookmark.fill" : "bookmark")
                        Text("\(shortcut.saveCount)")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(shortcut.isSaved ? Color.primaryPurple : Color.textSecondary)
                    .frame(width: 88, height: 44)
                    .background(shortcut.isSaved ? Color.primaryPurple.opacity(0.10) : Color.backgroundGray)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.borderGray.opacity(0.85), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.035), radius: 10, y: 4)
    }
}

private struct MetricPill: View {
    var icon: String
    var value: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
            Text(value)
                .lineLimit(1)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(Color.textSecondary)
        .padding(.horizontal, 9)
        .frame(height: 30)
        .background(Color.backgroundGray)
        .clipShape(Capsule())
    }
}
