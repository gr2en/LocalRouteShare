import SwiftUI

struct RouteProposalCard: View {
    var proposal: RouteProposal
    var onVote: () -> Void
    var onOpen: () -> Void = {}

    init(
        proposal: RouteProposal,
        onVote: @escaping () -> Void,
        onOpen: @escaping () -> Void = {}
    ) {
        self.proposal = proposal
        self.onVote = onVote
        self.onOpen = onOpen
    }

    private var buttonTitle: String {
        switch proposal.status {
        case .voting:
            return proposal.hasVoted ? "Voted (\(proposal.voteCount.formatted()))" : "Vote (\(proposal.voteCount.formatted()))"
        case .reviewing:
            return "Voted (\(proposal.voteCount.formatted()))"
        case .operating:
            return "Route Approved!"
        }
    }

    private var isVoteDisabled: Bool {
        proposal.status != .voting || proposal.hasVoted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onOpen) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.top, 3)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Text(proposal.startPoint)
                                .lineLimit(1)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.textSecondary.opacity(0.7))

                            Text(proposal.voteListEndPoint)
                                .lineLimit(1)
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.textPrimary)

                        Text(proposal.reason)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(2)
                            .lineSpacing(2)
                    }

                    Spacer(minLength: 8)

                    Text(proposal.status.displayText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(proposal.status.badgeTextColor)
                        .padding(.horizontal, 10)
                        .frame(height: 20)
                        .background(proposal.status.badgeBackgroundColor)
                        .clipShape(Capsule())
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                ProposalInlineMetric(icon: "clock", value: "15-minute walk")

                Rectangle()
                    .fill(Color.borderGray)
                    .frame(width: 1, height: 14)

                ProposalInlineMetric(icon: "person.2", value: "\(proposal.participantCount) students support this route")

                Spacer(minLength: 0)
            }

            Button(action: onVote) {
                Label(buttonTitle, systemImage: proposal.status == .operating ? "checkmark.seal.fill" : "hand.thumbsup")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(isVoteDisabled ? Color.textSecondary : Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        Group {
                            if isVoteDisabled {
                                Color.lightGray
                            } else {
                                Color.primaryPurple
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isVoteDisabled)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.borderGray.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
    }
}

private struct ProposalInlineMetric: View {
    var icon: String
    var value: String

    var body: some View {
        Label(value, systemImage: icon)
            .font(.system(size: 11))
            .foregroundStyle(Color.textSecondary)
            .lineLimit(1)
    }
}

private extension RouteProposal {
    var voteListEndPoint: String {
        if endPoint.localizedCaseInsensitiveContains("Sinchon") {
            return "Sinchon St. Exit3"
        }
        return endPoint
    }
}

private extension RouteStatus {
    var badgeBackgroundColor: Color {
        switch self {
        case .voting:
            return Color.primaryPurple.opacity(0.10)
        case .reviewing:
            return Color(hex: "#FEF9C2")
        case .operating:
            return Color(hex: "#DCFCE7")
        }
    }

    var badgeTextColor: Color {
        switch self {
        case .voting:
            return Color.primaryPurple
        case .reviewing:
            return Color(hex: "#F59E0B")
        case .operating:
            return Color(hex: "#16A34A")
        }
    }
}

private struct ProposalMetric: View {
    var icon: String
    var value: String
    var label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(Color.primaryPurple)
            Text(value)
                .fontWeight(.bold)
            Text(label)
                .foregroundStyle(Color.textSecondary)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(Color.backgroundGray)
        .clipShape(Capsule())
    }
}
