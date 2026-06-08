import SwiftUI

struct SectionHeader: View {
    var title: String
    var subtitle: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Spacer()

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.primaryPurple)
            }
        }
    }
}
