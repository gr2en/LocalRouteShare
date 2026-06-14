import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var destinationQuery = ""
    @State private var selectedTag = "All"
    @State private var homePath: [HomeDestination] = []
    @State private var quickTags = ["Dorm", "Indoor"]
    @State private var isAddingTag = false
    @State private var draftTag = ""
    @State private var isMascotBlinking = false
    @State private var mascotWobbleAngle = 0.0
    @FocusState private var isTagFieldFocused: Bool

    private var popularShortcuts: [Shortcut] {
        Array(filteredShortcuts.sorted { $0.saveCount > $1.saveCount }.prefix(searchQuery.isEmpty ? 2 : 4))
    }

    private var filteredShortcuts: [Shortcut] {
        // Home search only shows real shortcuts that contain the user's keyword.
        viewModel.shortcuts.filter { shortcut in
            matchesSelectedTag(shortcut) && matchesShortcutSearch(shortcut)
        }
    }

    private var filteredRoutes: [RouteProposal] {
        // Route requests use the same keyword, so both home sections stay consistent.
        viewModel.routeProposals.filter(matchesProposalSearch)
    }

    private var popularRoutes: [RouteProposal] {
        Array(filteredRoutes.sorted { $0.voteCount > $1.voteCount }.prefix(searchQuery.isEmpty ? 2 : 4))
    }

    private var searchQuery: String {
        destinationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack(path: $homePath) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header

                    VStack(spacing: 14) {
                        HomeSectionTitle(
                            systemImage: "mappin.circle",
                            color: Color(hex: "#16C784"),
                            title: "Best Shortcuts This Week"
                        )

                        VStack(spacing: 12) {
                            if popularShortcuts.isEmpty {
                                HomeEmptyResultRow(title: "No matching shortcuts.")
                            } else {
                                ForEach(popularShortcuts) { shortcut in
                                    NavigationLink(value: HomeDestination.shortcut(shortcut.id)) {
                                        HomeShortcutSummaryCard(shortcut: shortcut)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        Divider()
                            .padding(.top, 14)
                            .padding(.horizontal, -20)

                        HomeSectionTitle(
                            systemImage: "flame.fill",
                            color: Color(hex: "#FF3D8B"),
                            title: "Trending Route Requests"
                        )

                        VStack(spacing: 14) {
                            if popularRoutes.isEmpty {
                                HomeEmptyResultRow(title: "No matching route requests.")
                            } else {
                                ForEach(popularRoutes) { proposal in
                                    HomeRouteRequestMiniCard(proposal: proposal) {
                                        homePath.append(.routeRequest(proposal.id))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 26)
                }
            }
            .background(Color.backgroundGray.ignoresSafeArea())
            .ignoresSafeArea(.container, edges: .top)
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .shortcut(let shortcutID):
                    ShortcutDetailView(shortcutID: shortcutID)
                        .environmentObject(viewModel)
                case .routeRequest(let proposalID):
                    RouteRequestDetailView(proposalID: proposalID)
                        .environmentObject(viewModel)
                }
            }
        }
    }

    private var header: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let headerContentOffset: CGFloat = 16

            ZStack(alignment: .topLeading) {
                LinearGradient(
                    colors: [
                        Color.primaryPurple.opacity(0.62),
                        Color.primaryBlue.opacity(0.82)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Button {
                    playMascotTapAnimation()
                } label: {
                    MascotHeroView(isBlinking: isMascotBlinking)
                }
                .buttonStyle(.plain)
                .rotationEffect(.degrees(mascotWobbleAngle), anchor: .bottom)
                .position(x: 76, y: 106 + headerContentOffset)
                .shadow(color: Color.primaryPurple.opacity(0.16), radius: 7, x: 0, y: 5)

                ZStack {
                    SpeechBubbleShape()
                        .fill(Color.white.opacity(0.20))
                        .frame(width: 130, height: 58)

                    Text("Top 5%\ncontributor!")
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.84)
                        .frame(width: 122, height: 46)
                        .offset(y: -3)
                }
                .frame(width: 150, height: 80)
                .rotationEffect(.degrees(4.0))
                .position(x: min(width - 202, 242), y: 76 + headerContentOffset)

                VStack(alignment: .trailing, spacing: 2) {
                    Text("My Local Score")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(hex: "#DBEAFE"))

                    Text(viewModel.userProfile.localScore.formatted(.number.grouping(.automatic)))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color.white)
                }
                .frame(width: 132, alignment: .trailing)
                .position(x: width - 82, y: 76 + headerContentOffset)

                HStack(spacing: 6) {
                    HomeStatPill(value: viewModel.userProfile.shortcutCount, title: "Routes")
                    HomeStatPill(value: viewModel.userProfile.votedRouteCount, title: "Votes")
                    HomeStatPill(value: viewModel.userProfile.receivedLikes, title: "Likes")
                }
                .frame(width: 264)
                .position(x: width - 138, y: 150 + headerContentOffset)

                SearchBar(
                    text: $destinationQuery,
                    placeholder: "Search Destination",
                    backgroundColor: Color.white
                )
                    .frame(width: max(width - 32, 0), height: 52)
                    .position(x: width / 2, y: 214 + headerContentOffset)

                tagScroller
                    .frame(width: max(width - 32, 0), height: 42)
                    .position(x: width / 2, y: 264 + headerContentOffset)
            }
        }
        .frame(height: 310)
    }

    private var tagScroller: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickTags, id: \.self) { tag in
                        HashtagChip(title: tag, isSelected: selectedTag == tag) {
                            selectedTag = selectedTag == tag ? "All" : tag
                        }
                        .id("tag-\(tag.lowercased())")
                    }

                    Button {
                        handleAddTagButton(proxy: proxy)
                    } label: {
                        Image(systemName: "plus")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.textPrimary)
                            .frame(width: 34, height: 34)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.borderGray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    if isAddingTag {
                        HStack(spacing: 0) {
                            Text("#")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.textSecondary)

                            TextField("tag", text: $draftTag)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.textPrimary)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($isTagFieldFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    commitDraftTag(proxy: proxy)
                                }
                        }
                        .padding(.horizontal, 12)
                        .frame(width: 96, height: 34)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.borderGray, lineWidth: 1)
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.94, anchor: .leading)))
                    }
                }
                .padding(.trailing, 16)
                .frame(height: 42)
            }
            .animation(.spring(response: 0.26, dampingFraction: 0.86), value: isAddingTag)
        }
    }

    private func handleAddTagButton(proxy: ScrollViewProxy) {
        if isAddingTag {
            commitDraftTag(proxy: proxy)
        } else {
            draftTag = ""
            isAddingTag = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTagFieldFocused = true
            }
        }
    }

    private func commitDraftTag(proxy: ScrollViewProxy) {
        let tag = draftTag
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "#"))

        guard tag.isEmpty == false else {
            isAddingTag = false
            isTagFieldFocused = false
            return
        }

        if quickTags.contains(where: { $0.localizedCaseInsensitiveCompare(tag) == .orderedSame }) == false {
            quickTags.append(tag)
        }

        selectedTag = tag
        draftTag = ""
        isAddingTag = false
        isTagFieldFocused = false

        // After adding a tag, return the scroller to the first chip for a stable layout.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                if let firstTag = quickTags.first {
                    proxy.scrollTo("tag-\(firstTag.lowercased())", anchor: .leading)
                }
            }
        }
    }

    private func matchesSelectedTag(_ shortcut: Shortcut) -> Bool {
        guard selectedTag != "All" else { return true }

        return shortcut.title.localizedCaseInsensitiveContains(selectedTag)
        || shortcut.startPoint.localizedCaseInsensitiveContains(selectedTag)
        || shortcut.endPoint.localizedCaseInsensitiveContains(selectedTag)
        || shortcut.routeDescription.localizedCaseInsensitiveContains(selectedTag)
        || shortcut.tags.contains { tag in
            tag.localizedCaseInsensitiveContains(selectedTag)
        }
    }

    private func matchesShortcutSearch(_ shortcut: Shortcut) -> Bool {
        guard searchQuery.isEmpty == false else { return true }

        return shortcut.title.localizedCaseInsensitiveContains(searchQuery)
        || shortcut.startPoint.localizedCaseInsensitiveContains(searchQuery)
        || shortcut.endPoint.localizedCaseInsensitiveContains(searchQuery)
        || shortcut.routeDescription.localizedCaseInsensitiveContains(searchQuery)
        || shortcut.tags.contains { tag in
            tag.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    private func matchesProposalSearch(_ proposal: RouteProposal) -> Bool {
        guard searchQuery.isEmpty == false else { return true }

        return proposal.startPoint.localizedCaseInsensitiveContains(searchQuery)
        || proposal.endPoint.localizedCaseInsensitiveContains(searchQuery)
        || proposal.reason.localizedCaseInsensitiveContains(searchQuery)
        || proposal.expectedBenefits.contains { benefit in
            benefit.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    private func playMascotTapAnimation() {
        // A short blink and wobble makes the mascot feel interactive without changing state.
        withAnimation(.easeInOut(duration: 0.07)) {
            isMascotBlinking = true
        }

        withAnimation(.interpolatingSpring(stiffness: 260, damping: 12)) {
            mascotWobbleAngle = 7.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
            withAnimation(.easeInOut(duration: 0.08)) {
                isMascotBlinking = false
            }

            withAnimation(.interpolatingSpring(stiffness: 260, damping: 12)) {
                mascotWobbleAngle = -6
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            withAnimation(.interpolatingSpring(stiffness: 260, damping: 14)) {
                mascotWobbleAngle = 3.5
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
            withAnimation(.interpolatingSpring(stiffness: 220, damping: 16)) {
                mascotWobbleAngle = 0
            }
        }
    }
}

private enum HomeDestination: Hashable {
    case shortcut(UUID)
    case routeRequest(UUID)
}

private struct MascotHeroView: View {
    var isBlinking: Bool

    var body: some View {
        ZStack {
            Image("RouteMascot")
                .renderingMode(.original)
                .resizable()
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .frame(width: 112, height: 126)

            if isBlinking {
                HStack(spacing: 12) {
                    MascotBlinkEye()
                    MascotBlinkEye()
                }
                .offset(x: -2, y: -4)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            }
        }
        .frame(width: 112, height: 126)
        .contentShape(Rectangle())
        .accessibilityLabel("Route mascot")
    }
}

private struct MascotBlinkEye: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(0.96))
                .frame(width: 20, height: 16)

            Capsule()
                .fill(Color(hex: "#1E3A8A"))
                .frame(width: 18, height: 4)
                .offset(y: 1)
        }
    }
}

private struct HomeStatPill: View {
    let value: Int
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value.formatted())
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white)

            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(Color(hex: "#DBEAFE"))
        }
        .frame(width: 84, height: 64)
        .background(Color.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct HomeShortcutSummaryCard: View {
    var shortcut: Shortcut

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(shortcut.homeSummaryTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)

            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: "#D1D5DB"))
                    .frame(width: 18, height: 18)

                Text(shortcut.homeSummaryAuthor)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.textSecondary)

                Image(systemName: "star.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color(hex: "#F0B100"))

                Text(String(format: "%.1f", shortcut.rating))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.textPrimary)
            }

            HStack(spacing: 12) {
                Label(shortcut.compactEstimatedTime, systemImage: "clock")

                Divider()
                    .frame(height: 18)

                Label("\(shortcut.saveCount.formatted()) likes", systemImage: "hand.thumbsup")
            }
            .font(.system(size: 9))
            .foregroundStyle(Color.textSecondary)

            HStack(spacing: 8) {
                ForEach(shortcut.homeSummaryTags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(size: 9))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 9)
                        .frame(height: 20)
                        .background(Color.lightGray)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 96)
        .padding(.horizontal, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.lightGray, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 4, y: 1)
    }
}

private struct HomeRouteRequestMiniCard: View {
    var proposal: RouteProposal
    var onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    HStack(spacing: 6) {
                        Text(proposal.homeStartPoint)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Image(systemName: "arrow.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.textSecondary.opacity(0.65))

                        Text(proposal.homeEndPoint)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text(proposal.homeBadge)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color(hex: "#F6339A"))
                        .padding(.horizontal, 10)
                        .frame(height: 22)
                        .background(Color(hex: "#FFE2E2"))
                        .clipShape(Capsule())
                }

                HStack(spacing: 12) {
                    Label(proposal.voteCount.formatted(), systemImage: "hand.thumbsup")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.primaryPurple)

                    Label("\(proposal.participantCount.formatted()) supporters", systemImage: "person.2")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.textSecondary)

                    Spacer(minLength: 4)

                    Text(proposal.status.displayText)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(proposal.status.tintColor)
                        .padding(.horizontal, 10)
                        .frame(height: 22)
                        .background(proposal.status.tintColor.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 70)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.lightGray, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 4, y: 1)
        }
        .buttonStyle(.plain)
    }
}

private struct HomeSectionTitle: View {
    let systemImage: String
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.textPrimary)

            Spacer()
        }
    }
}

private struct HomeEmptyResultRow: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .frame(height: 54)
            .background(Color.white.opacity(0.86))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.lightGray, lineWidth: 1)
            )
    }
}

private struct SpeechBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let bubbleRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height - 10
        )
        var path = RoundedRectangle(cornerRadius: 28, style: .continuous).path(in: bubbleRect)
        let tail = Path { tailPath in
            tailPath.move(to: CGPoint(x: rect.minX + 40, y: bubbleRect.maxY - 1))
            tailPath.addLine(to: CGPoint(x: rect.minX + 28, y: rect.maxY))
            tailPath.addLine(to: CGPoint(x: rect.minX + 56, y: bubbleRect.maxY - 1))
            tailPath.closeSubpath()
        }
        path.addPath(tail)
        return path
    }
}

private struct SmartRouteView: View {
    @Environment(\.dismiss) private var dismiss
    var destinationQuery: String

    private var destination: String {
        let trimmed = destinationQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Gangnam Station" : trimmed
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    weatherCard
                    routeInputCard
                    recommendedRoute
                    Button("Show 2 More Routes") {}
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.primaryPurple)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.primaryPurple.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Button {
                        dismiss()
                    } label: {
                        Label("View Full Route", systemImage: "map")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.primaryPurple)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(Color.backgroundGray.ignoresSafeArea())
            .navigationTitle("Smart Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Smart Route")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.textPrimary)

            Text("Best route considering weather and traffic")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var weatherCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "cloud.rain.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color.primaryBlue)
                .frame(width: 44, height: 44)
                .background(Color.primaryBlue.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text("Rainy Now")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                Text("Fine dust is bad")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("18°")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                Text("Rain 70%")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }

    private var routeInputCard: some View {
        VStack(spacing: 0) {
            SmartRouteInputRow(icon: "circle.fill", title: "Yonsei University Dormitory", tint: Color.primaryPurple)
            Divider()
                .padding(.leading, 44)
            SmartRouteInputRow(icon: "mappin.circle.fill", title: destination, tint: Color.primaryBlue)
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }

    private var recommendedRoute: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recommended Route")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                Label("92 pts", systemImage: "sparkles")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.primaryPurple)
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Optimal Route")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.primaryPurple)
                        .padding(.horizontal, 12)
                        .frame(height: 24)
                        .background(Color.primaryPurple.opacity(0.10))
                        .clipShape(Capsule())

                    Spacer()

                    Label("32 min", systemImage: "clock")
                    Label("8,500 KRW", systemImage: "wonsign.circle")
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.textSecondary)

                VStack(spacing: 12) {
                    SmartRouteStep(icon: "tram.fill", title: "Line 2", subtitle: nil, time: "15 min")
                    SmartRouteStep(icon: "figure.walk", title: "Walk 3 min", subtitle: "Use indoor passage", time: "3 min")
                    SmartRouteStep(icon: "car.fill", title: "Taxi", subtitle: nil, time: "14 min")
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Why this route?")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    Text("Subway covers 80% of the trip, so you avoid rain.")
                    Text("Lower congestion than the direct route.")
                    Text("Only 3 minutes of walking, with an indoor path.")
                }
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
    }
}

private struct SmartRouteInputRow: View {
    var icon: String
    var title: String
    var tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 28)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
    }
}

private struct SmartRouteStep: View {
    var icon: String
    var title: String
    var subtitle: String?
    var time: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.primaryPurple)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                }
            }

            Spacer()

            Text(time)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.textSecondary)
        }
    }
}

private extension Shortcut {
    var homeSummaryTitle: String {
        if title.contains("→") || title.contains("->") {
            return title
                .replacingOccurrences(of: " -> ", with: " → ")
                .replacingOccurrences(of: "->", with: "→")
        }

        return "\(startPoint) → \(endPoint)"
    }

    var homeSummaryAuthor: String {
        author
    }

    var homeSummaryTags: [String] {
        Array(tags.prefix(3)).map { tag in
            switch tag {
            case "Rainy Day":
                return "Raining"
            case "Indoor":
                return "Indoor Routes"
            case "Elevator":
                return "Elevators"
            default:
                return tag
            }
        }
    }

    var compactEstimatedTime: String {
        estimatedTime
            .replacingOccurrences(of: " min", with: "m")
            .replacingOccurrences(of: " sec", with: "s")
    }
}

private extension RouteProposal {
    var homeStartPoint: String {
        startPoint
    }

    var homeEndPoint: String {
        endPoint
    }

    var homeBadge: String {
        "HOT"
    }
}
