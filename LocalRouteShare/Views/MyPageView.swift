import SwiftUI

struct MyPageView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var profilePath: [ProfileDestination] = []
    @State private var selectedBadge: Badge?

    private var profile: UserProfile {
        viewModel.userProfile
    }

    private var allMyShortcuts: [Shortcut] {
        viewModel.shortcuts.filter { $0.author == profile.nickname }
    }

    private var recentMyShortcuts: [Shortcut] {
        Array(allMyShortcuts.prefix(3))
    }

    private var savedShortcuts: [Shortcut] {
        viewModel.shortcuts.filter(\.isSaved)
    }

    private var recentSavedShortcuts: [Shortcut] {
        Array(savedShortcuts.prefix(2))
    }

    private var latestSavedRouteText: String {
        recentSavedShortcuts.first?.shortTitle ?? "No saved routes yet"
    }

    private var latestSharedRouteText: String {
        recentMyShortcuts.first?.shortTitle ?? "No shared routes yet"
    }

    var body: some View {
        NavigationStack(path: $profilePath) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    profileHeader

                    VStack(spacing: 22) {
                        activitySection
                        savedRouteSection
                        achievementSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
            }
            .background(Color.backgroundGray.ignoresSafeArea())
            .navigationDestination(for: ProfileDestination.self) { destination in
                destinationView(for: destination)
            }
        }
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailSheet(badge: badge)
                .presentationDetents([.height(300)])
        }
    }

    @ViewBuilder
    private func destinationView(for destination: ProfileDestination) -> some View {
        switch destination {
        case .rewards:
            ProfileRewardsView()
                .environmentObject(viewModel)
        case .shortcut(let shortcutID):
            ShortcutDetailView(shortcutID: shortcutID)
                .environmentObject(viewModel)
        case .sharedShortcuts:
            ProfileSharedShortcutsView()
                .environmentObject(viewModel)
        case .votedRoutes:
            ProfileVotedRoutesView()
                .environmentObject(viewModel)
        case .engagement:
            ProfileEngagementView()
                .environmentObject(viewModel)
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image("RouteMascot")
                    .renderingMode(.original)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 102, height: 116)
                    .shadow(color: Color.primaryPurple.opacity(0.22), radius: 12, x: 0, y: 8)

                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.nickname)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text("\(profile.level) · \(profile.school)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.76))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
                .layoutPriority(1)

                Spacer()
            }

            Button {
                profilePath.append(.rewards)
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("My Local Score")
                            .font(.subheadline)
                            .foregroundStyle(Color.white.opacity(0.72))
                        
                        Spacer()
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.white.opacity(0.70))
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(profile.localScore.formatted(.number.grouping(.automatic)))
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.white)
                        
                        Text("+\(profile.weeklyIncrease) This week")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(Color.white.opacity(0.72))
                    }
                    
                    Text("Top 5% Contributor")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.70))
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [Color.primaryPurple.opacity(0.72), Color.primaryBlue.opacity(0.58)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("My Activity")
                .font(.title2.weight(.heavy))
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 14) {
                Button {
                    profilePath.append(.engagement)
                } label: {
                    ProfileActivityRow(
                        icon: "heart",
                        title: "Saves",
                        subtitle: "Latest: \(latestSavedRouteText)",
                        value: profile.receivedLikes.formatted(),
                        tint: Color(hex: "#FF5A1F")
                    )
                }
                .buttonStyle(.plain)

                Button {
                    profilePath.append(.sharedShortcuts)
                } label: {
                    ProfileActivityRow(
                        icon: "mappin.circle",
                        title: "Routes Shared",
                        subtitle: "Latest: \(latestSharedRouteText)",
                        value: profile.shortcutCount.formatted(),
                        tint: Color(hex: "#16A34A")
                    )
                }
                .buttonStyle(.plain)

                Button {
                    profilePath.append(.votedRoutes)
                } label: {
                    ProfileActivityRow(
                        icon: "hand.thumbsup",
                        title: "Routes Voted",
                        subtitle: "5 Votes This Month",
                        value: profile.votedRouteCount.formatted(),
                        tint: Color.primaryPurple
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.07), radius: 10, y: 4)
    }

    private var savedRouteSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("My Saved Routes")
                .font(.title2.weight(.heavy))
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 18)
                .padding(.top, 20)
                .padding(.bottom, 14)

            if recentSavedShortcuts.isEmpty {
                Text("No saved routes yet.")
                    .font(.subheadline)
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
            } else {
                ForEach(Array(recentSavedShortcuts.enumerated()), id: \.element.id) { index, shortcut in
                    NavigationLink(value: ProfileDestination.shortcut(shortcut.id)) {
                        ProfileSavedRouteRow(shortcut: shortcut)
                    }
                    .buttonStyle(.plain)

                    if index < recentSavedShortcuts.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
    }

    private var achievementSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Image(systemName: "medal")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color(hex: "#EAB308"))

                Text("Achievements")
                    .font(.title2.weight(.heavy))
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textSecondary)
            }

            HStack(spacing: 12) {
                ForEach(Array(profile.badges.prefix(3))) { badge in
                    Button {
                        selectedBadge = badge
                    } label: {
                        AchievementTile(badge: badge)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: 4)
    }

}

private enum ProfileDestination: Hashable {
    case rewards
    case shortcut(UUID)
    case sharedShortcuts
    case votedRoutes
    case engagement
}

private struct ProfileActivityRow: View {
    var icon: String
    var title: String
    var subtitle: String
    var value: String
    var tint: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(Color.backgroundGray)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Spacer()

            Text(value)
                .font(.title3.weight(.heavy))
                .foregroundStyle(Color.textSecondary)
        }
        .contentShape(Rectangle())
    }
}

private struct ProfileSavedRouteRow: View {
    var shortcut: Shortcut

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text(shortcut.shortTitle)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    Label(String(format: "%.1f", shortcut.rating), systemImage: "star.fill")
                        .foregroundStyle(Color(hex: "#F2A900"))

                    Text("•")
                        .foregroundStyle(Color.borderGray)

                    Label(shortcut.saveCount.formatted(), systemImage: "hand.thumbsup")
                        .foregroundStyle(Color.textSecondary)
                }
                .font(.subheadline.weight(.semibold))

                HStack(spacing: 6) {
                    ForEach(shortcut.profileDisplayTags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, 8)
                            .frame(height: 26)
                            .background(Color.lightGray)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .contentShape(Rectangle())
    }
}

private struct AchievementTile: View {
    var badge: Badge

    var body: some View {
        VStack(spacing: 12) {
            Text(badge.emoji)
                .font(.system(size: 34))
                .frame(height: 42)

            Text(badge.title)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 128)
        .padding(.horizontal, 8)
        .background(Color(hex: "#FFFBEB"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(hex: "#FDE047"), lineWidth: 1.5)
        )
    }
}

private extension Shortcut {
    var shortTitle: String {
        if title.contains("→") || title.contains("->") {
            return title
                .replacingOccurrences(of: " -> ", with: " → ")
                .replacingOccurrences(of: "->", with: "→")
        }

        if title.contains(" to ") {
            return title.replacingOccurrences(of: " to ", with: " → ")
        }

        return "\(startPoint) → \(endPoint)"
    }

    var profileDisplayTags: [String] {
        tags.map { tag in
            switch tag {
            case "Rainy Day":
                return "Rainy"
            case "Hot Weather":
                return "Hot"
            case "Step-free":
                return "Accessible"
            default:
                return tag
            }
        }
    }
}

private struct ProfileShortcutRowContent: View {
    var shortcut: Shortcut

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "map.fill")
                .foregroundStyle(Color.primaryPurple)
                .frame(width: 34, height: 34)
                .background(Color.primaryPurple.opacity(0.10))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(shortcut.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                    .lineLimit(2)

                Text("\(shortcut.estimatedTime) - \(shortcut.distance)")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            Label("\(shortcut.saveCount)", systemImage: "bookmark.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.primaryPurple)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)
        }
    }
}

private struct EditableProfileShortcutRow: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var shortcut: Shortcut

    @State private var isShowingEdit = false
    @State private var isConfirmingDelete = false

    var body: some View {
        HStack(spacing: 10) {
            NavigationLink(value: ProfileDestination.shortcut(shortcut.id)) {
                ProfileShortcutRowContent(shortcut: shortcut)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Menu {
                Button {
                    isShowingEdit = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button(role: .destructive) {
                    isConfirmingDelete = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 34, height: 34)
                    .background(Color.backgroundGray)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
        .sheet(isPresented: $isShowingEdit) {
            EditShortcutView(shortcut: shortcut)
                .environmentObject(viewModel)
        }
        .alert("Delete Shortcut?", isPresented: $isConfirmingDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteShortcut(shortcutID: shortcut.id)
            }
        } message: {
            Text("This removes the shortcut from your shared routes. The action cannot be undone.")
        }
    }
}

private struct ProfileSharedShortcutsView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    private var shortcuts: [Shortcut] {
        viewModel.shortcuts.filter { $0.author == viewModel.userProfile.nickname }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Routes Shared", subtitle: "\(shortcuts.count) routes")

                if shortcuts.isEmpty {
                    ProfileEmptyState(icon: "map", title: "No shortcuts yet", subtitle: "Shared routes will appear here.")
                } else {
                    ForEach(shortcuts) { shortcut in
                        EditableProfileShortcutRow(shortcut: shortcut)
                            .environmentObject(viewModel)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 18)
        }
        .background(Color.backgroundGray.ignoresSafeArea())
        .navigationTitle("Routes Shared")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ProfileVotedRoutesView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    private var votedRoutes: [RouteProposal] {
        viewModel.routeProposals.filter(\.hasVoted)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Voted Routes", subtitle: "\(votedRoutes.count) proposals")

                if votedRoutes.isEmpty {
                    ProfileEmptyState(icon: "bus", title: "No votes yet", subtitle: "Route proposals you vote for will appear here.")
                } else {
                    ForEach(votedRoutes) { proposal in
                        RouteProposalCard(proposal: proposal) {
                            viewModel.voteRouteProposal(routeID: proposal.id)
                        }
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 18)
        }
        .background(Color.backgroundGray.ignoresSafeArea())
        .navigationTitle("Voted Routes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ProfileEngagementView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    private var sharedShortcuts: [Shortcut] {
        viewModel.shortcuts
            .filter { $0.author == viewModel.userProfile.nickname }
            .sorted { $0.saveCount > $1.saveCount }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Saves", subtitle: "Routes people saved from your profile")

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(viewModel.userProfile.receivedLikes)")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.textPrimary)

                    Text("Total saves received")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.borderGray, lineWidth: 1)
                )

                if sharedShortcuts.isEmpty {
                    ProfileEmptyState(icon: "bookmark", title: "No engagement yet", subtitle: "Share a shortcut to start collecting saves.")
                } else {
                    ForEach(sharedShortcuts) { shortcut in
                        EditableProfileShortcutRow(shortcut: shortcut)
                            .environmentObject(viewModel)
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 18)
        }
        .background(Color.backgroundGray.ignoresSafeArea())
        .navigationTitle("Saves")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ProfileRewardsView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    private var profile: UserProfile {
        viewModel.userProfile
    }

    private var sharedShortcuts: [Shortcut] {
        viewModel.shortcuts.filter { $0.author == profile.nickname }
    }

    private var votedRoutes: [RouteProposal] {
        viewModel.routeProposals.filter(\.hasVoted)
    }

    private var photoMarkerCount: Int {
        sharedShortcuts.reduce(0) { $0 + $1.photoMarkers.count }
    }

    private var hasRainyDayRoute: Bool {
        sharedShortcuts.contains { $0.tags.contains("Rainy Day") }
    }

    private let levels: [RewardLevel] = [
        RewardLevel(name: "Newcomer", score: 0),
        RewardLevel(name: "Route Scout", score: 100),
        RewardLevel(name: "Campus Guide", score: 300),
        RewardLevel(name: "Shortcut Expert", score: 700),
        RewardLevel(name: "Local Master", score: 1500),
        RewardLevel(name: "Local Legend", score: 3000)
    ]

    private var currentLevel: RewardLevel {
        levels.last { profile.localScore >= $0.score } ?? levels[0]
    }

    private var nextLevel: RewardLevel? {
        levels.first { profile.localScore < $0.score }
    }

    private var levelProgress: Double {
        guard let nextLevel else { return 1 }
        let earnedInLevel = profile.localScore - currentLevel.score
        let levelSpan = max(1, nextLevel.score - currentLevel.score)
        return min(1, max(0, Double(earnedInLevel) / Double(levelSpan)))
    }

    private var rewardItems: [RewardHistoryItem] {
        var items: [RewardHistoryItem] = []

        for shortcut in sharedShortcuts {
            items.append(
                RewardHistoryItem(
                    id: "shortcut-\(shortcut.id.uuidString)",
                    icon: "map.fill",
                    title: "Shortcut shared",
                    detail: shortcut.title,
                    points: 10,
                    tint: .primaryPurple
                )
            )

            if shortcut.routePoints.isEmpty == false {
                items.append(
                    RewardHistoryItem(
                        id: "gps-\(shortcut.id.uuidString)",
                        icon: "location.fill",
                        title: "GPS route bonus",
                        detail: "\(shortcut.routePoints.count) recorded points",
                        points: 15,
                        tint: .buttonBlue
                    )
                )
            }

            let photoPoints = min(shortcut.photoMarkers.count * 2, 10)
            if photoPoints > 0 {
                items.append(
                    RewardHistoryItem(
                        id: "photos-\(shortcut.id.uuidString)",
                        icon: "camera.fill",
                        title: "Photo marker bonus",
                        detail: "\(shortcut.photoMarkers.count) markers on \(shortcut.title)",
                        points: photoPoints,
                        tint: Color(hex: "#F59E0B")
                    )
                )
            }
        }

        if votedRoutes.isEmpty == false {
            items.append(
                RewardHistoryItem(
                    id: "votes",
                    icon: "checkmark.circle.fill",
                    title: "Route votes",
                    detail: "\(votedRoutes.count) proposals supported",
                    points: votedRoutes.count * 3,
                    tint: Color(hex: "#10B981")
                )
            )
        }

        if profile.receivedLikes > 0 {
            items.append(
                RewardHistoryItem(
                    id: "saves",
                    icon: "bookmark.fill",
                    title: "Community saves",
                    detail: "\(profile.receivedLikes) saves and likes received",
                    points: profile.receivedLikes,
                    tint: Color(hex: "#8B5CF6")
                )
            )
        }

        let computedPoints = items.reduce(0) { $0 + $1.points }
        let remainingPoints = max(0, profile.localScore - computedPoints)
        if remainingPoints > 0 {
            items.append(
                RewardHistoryItem(
                    id: "previous-balance",
                    icon: "sparkles",
                    title: "Previous score balance",
                    detail: "Existing progress carried into this MVP profile",
                    points: remainingPoints,
                    tint: Color.textSecondary
                )
            )
        }

        return items
    }

    private var missions: [RewardMission] {
        [
            RewardMission(
                title: "Share 1 GPS-recorded shortcut",
                reward: 20,
                progress: sharedShortcuts.contains { $0.routePoints.isEmpty == false } ? 1 : 0,
                target: 1
            ),
            RewardMission(
                title: "Vote on 3 route proposals",
                reward: 10,
                progress: min(votedRoutes.count, 3),
                target: 3
            ),
            RewardMission(
                title: "Add 3 photo markers",
                reward: 10,
                progress: min(photoMarkerCount, 3),
                target: 3
            ),
            RewardMission(
                title: "Share a rainy-day route",
                reward: 15,
                progress: hasRainyDayRoute ? 1 : 0,
                target: 1
            )
        ]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                scoreSummary
                rewardHistorySection
                weeklyMissionsSection
                scoringRulesSection
            }
            .padding(20)
            .padding(.bottom, 18)
        }
        .background(Color.backgroundGray.ignoresSafeArea())
        .navigationTitle("Reward History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var scoreSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Local Score")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)

                    Text(profile.localScore.formatted(.number.grouping(.automatic)))
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.textPrimary)
                }

                Spacer()

                Text(currentLevel.name)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.primaryPurple)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Color.primaryPurple.opacity(0.10))
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: levelProgress)
                    .tint(Color.primaryPurple)

                if let nextLevel {
                    Text("\(max(0, nextLevel.score - profile.localScore).formatted(.number.grouping(.automatic))) points to \(nextLevel.name)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                } else {
                    Text("Top level reached")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }

    private var rewardHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Reward History", subtitle: "How your Local Score is built")

            VStack(spacing: 8) {
                ForEach(rewardItems) { item in
                    RewardHistoryRow(item: item)
                }
            }
        }
    }

    private var weeklyMissionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Weekly Missions", subtitle: "Complete missions for bonus points")

            VStack(spacing: 8) {
                ForEach(missions) { mission in
                    RewardMissionRow(mission: mission)
                }
            }
        }
    }

    private var scoringRulesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Scoring Rules")

            VStack(spacing: 0) {
                RewardRuleRow(title: "Shortcut shared", points: "+10")
                Divider().padding(.leading, 44)
                RewardRuleRow(title: "GPS route included", points: "+15")
                Divider().padding(.leading, 44)
                RewardRuleRow(title: "Photo marker", points: "+2 each, max +10")
                Divider().padding(.leading, 44)
                RewardRuleRow(title: "Route vote", points: "+3")
                Divider().padding(.leading, 44)
                RewardRuleRow(title: "Community save/like", points: "+1")
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
    }
}

private struct RewardLevel: Identifiable {
    let id = UUID()
    var name: String
    var score: Int
}

private struct RewardHistoryItem: Identifiable {
    var id: String
    var icon: String
    var title: String
    var detail: String
    var points: Int
    var tint: Color
}

private struct RewardMission: Identifiable {
    let id = UUID()
    var title: String
    var reward: Int
    var progress: Int
    var target: Int

    var isComplete: Bool {
        progress >= target
    }

    var progressValue: Double {
        guard target > 0 else { return 0 }
        return min(1, Double(progress) / Double(target))
    }
}

private struct RewardHistoryRow: View {
    var item: RewardHistoryItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(item.tint)
                .frame(width: 36, height: 36)
                .background(item.tint.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Text("+\(item.points)")
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }
}

private struct RewardMissionRow: View {
    var mission: RewardMission

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mission.title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.textPrimary)

                    Text("\(mission.progress)/\(mission.target) complete")
                        .font(.caption)
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Text("+\(mission.reward)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(mission.isComplete ? Color(hex: "#10B981") : Color.primaryPurple)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background((mission.isComplete ? Color(hex: "#10B981") : Color.primaryPurple).opacity(0.10))
                    .clipShape(Capsule())
            }

            ProgressView(value: mission.progressValue)
                .tint(mission.isComplete ? Color(hex: "#10B981") : Color.primaryPurple)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }
}

private struct RewardRuleRow: View {
    var title: String
    var points: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(Color.primaryPurple)
                .frame(width: 32, height: 32)
                .background(Color.primaryPurple.opacity(0.10))
                .clipShape(Circle())

            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.textPrimary)

            Spacer()

            Text(points)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.vertical, 9)
    }
}

private struct BadgeDetailSheet: View {
    var badge: Badge

    var body: some View {
        VStack(spacing: 16) {
            Text(badge.emoji)
                .font(.system(size: 48))
                .frame(width: 76, height: 76)
                .background(badge.isUnlocked ? Color.primaryPurple.opacity(0.10) : Color.lightGray)
                .clipShape(Circle())
                .saturation(badge.isUnlocked ? 1 : 0)
                .opacity(badge.isUnlocked ? 1 : 0.55)

            VStack(spacing: 7) {
                Text(badge.title)
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(Color.textPrimary)

                Text(badge.subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)

                Text(badge.isUnlocked ? "Unlocked" : "Locked")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(badge.isUnlocked ? Color(hex: "#10B981") : Color.textSecondary)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background((badge.isUnlocked ? Color(hex: "#10B981") : Color.textSecondary).opacity(0.10))
                    .clipShape(Capsule())
            }

            Text(badge.isUnlocked ? "Keep sharing routes to climb the local leaderboard." : "Keep contributing routes and votes to unlock this badge.")
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(24)
    }
}

private struct ProfileEmptyState: View {
    var icon: String
    var title: String
    var subtitle: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2.weight(.bold))
                .foregroundStyle(Color.textSecondary)

            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.textPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }
}
