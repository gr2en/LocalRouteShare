import SwiftUI

struct RouteVoteView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var isShowingAddProposal = false
    @State private var selectedFilter: RouteFilter = .popular
    @State private var proposalPath: [UUID] = []

    private var visibleProposals: [RouteProposal] {
        switch selectedFilter {
        case .popular:
            return viewModel.routeProposals.sorted { $0.voteCount > $1.voteCount }
        case .voting:
            return viewModel.routeProposals.filter { $0.status == .voting }
        case .reviewing:
            return viewModel.routeProposals.filter { $0.status == .reviewing }
        case .operating:
            return viewModel.routeProposals.filter { $0.status == .operating }
        }
    }

    var body: some View {
        NavigationStack(path: $proposalPath) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Route Requests & Voting")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.textPrimary)

                        Text("Vote for the routes you want to see")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.textSecondary)
                    }

                    Button {
                        isShowingAddProposal = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 34, height: 34)
                                .background(Color.white.opacity(0.16))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Suggest a New Route")
                                    .font(.system(size: 15, weight: .bold))

                                Text("Vote for Better Routes")
                                    .font(.system(size: 11))
                                    .opacity(0.82)
                            }

                            Spacer()

                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 16)
                        .frame(height: 72)
                        .background(
                            Color.primaryPurple
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    HStack {
                        Spacer()

                        Menu {
                            ForEach(RouteFilter.allCases, id: \.self) { filter in
                                Button(filter.title) {
                                    selectedFilter = filter
                                }
                            }
                        } label: {
                            Text(selectedFilter.title)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.textPrimary)
                                .padding(.horizontal, 12)
                                .frame(height: 28)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.borderGray, lineWidth: 1)
                                )
                        }
                    }

                    LazyVStack(spacing: 14) {
                        ForEach(visibleProposals) { proposal in
                            RouteProposalCard(
                                proposal: proposal,
                                onVote: {
                                    viewModel.voteRouteProposal(routeID: proposal.id)
                                },
                                onOpen: {
                                    proposalPath.append(proposal.id)
                                }
                            )
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 18)
            }
            .background(Color.backgroundGray.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: UUID.self) { proposalID in
                RouteRequestDetailView(proposalID: proposalID)
                    .environmentObject(viewModel)
            }
            .navigationDestination(isPresented: $isShowingAddProposal) {
                AddRouteProposalView(embedsInNavigationStack: false)
                    .environmentObject(viewModel)
            }
        }
    }
}

private enum RouteFilter: CaseIterable {
    case popular
    case voting
    case reviewing
    case operating

    var title: String {
        switch self {
        case .popular:
            return "Most Popular"
        case .voting:
            return "Voting"
        case .reviewing:
            return "Reviewing"
        case .operating:
            return "Operating"
        }
    }
}

struct RouteRequestDetailView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    let proposalID: UUID

    private var proposal: RouteProposal? {
        viewModel.routeProposals.first { $0.id == proposalID }
    }

    var body: some View {
        Group {
            if let proposal {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        detailHeader(for: proposal)
                        routeMap
                        fullRouteSection(for: proposal)
                        detailSection(title: "Why Students Need This Route") {
                            Text(proposal.reason)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.textSecondary)
                                .lineSpacing(3)
                        }
                        commentsSection
                        benefitsSection(for: proposal)
                        statusSection(for: proposal)
                        supportersSection(for: proposal)
                        voteButton(for: proposal)
                    }
                    .padding(20)
                    .padding(.bottom, 18)
                }
            } else {
                Text("Route request not found.")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.backgroundGray.ignoresSafeArea())
        .navigationTitle("Route Request Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: "\(proposal?.startPoint ?? "") → \(proposal?.endPoint ?? "")") {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }

    private func detailHeader(for proposal: RouteProposal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(proposal.startPoint)
                    .lineLimit(1)
                Image(systemName: "arrow.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.textSecondary)
                Text(proposal.detailEndPoint)
                    .lineLimit(1)
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(Color.textPrimary)

            HStack(spacing: 12) {
                Label(proposal.voteCount.formatted(), systemImage: "hand.thumbsup")
                    .foregroundStyle(Color.primaryPurple)
                Label("Andrew Lee", systemImage: "person.fill")
                Text(proposal.status.displayText)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(proposal.status.detailBadgeTextColor)
                    .padding(.horizontal, 10)
                    .frame(height: 20)
                    .background(proposal.status.detailBadgeBackgroundColor)
                    .clipShape(Capsule())
            }
            .font(.system(size: 11))
            .foregroundStyle(Color.textSecondary)
        }
    }

    private var routeMap: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#EAF4FF"), Color(hex: "#FFF5E8")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(hex: "#DDEAF7").opacity(0.85))
                    .frame(width: width * 0.58, height: height * 0.54)
                    .rotationEffect(.degrees(-9))
                    .position(x: width * 0.70, y: height * 0.40)

                mapRoad(width: width * 1.18, height: 13, color: Color.white.opacity(0.92))
                    .rotationEffect(.degrees(-8))
                    .position(x: width * 0.48, y: height * 0.34)

                mapRoad(width: width * 0.95, height: 10, color: Color.white.opacity(0.88))
                    .rotationEffect(.degrees(17))
                    .position(x: width * 0.54, y: height * 0.58)

                mapRoad(width: width * 0.78, height: 8, color: Color(hex: "#F8C163").opacity(0.55))
                    .rotationEffect(.degrees(-2))
                    .position(x: width * 0.38, y: height * 0.22)

                Path { path in
                    path.move(to: CGPoint(x: width * 0.08, y: height * 0.65))
                    path.addCurve(
                        to: CGPoint(x: width * 0.52, y: height * 0.42),
                        control1: CGPoint(x: width * 0.21, y: height * 0.43),
                        control2: CGPoint(x: width * 0.38, y: height * 0.52)
                    )
                    path.addCurve(
                        to: CGPoint(x: width * 0.92, y: height * 0.50),
                        control1: CGPoint(x: width * 0.68, y: height * 0.28),
                        control2: CGPoint(x: width * 0.78, y: height * 0.62)
                    )
                }
                .stroke(Color.primaryPurple, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                ForEach(routePreviewStops(width: width, height: height), id: \.label) { stop in
                    VStack(spacing: 3) {
                        Circle()
                            .fill(Color.primaryPurple)
                            .frame(width: 9, height: 9)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))

                        Text(stop.label)
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, 5)
                            .frame(height: 16)
                            .background(Color.white.opacity(0.88))
                            .clipShape(Capsule())
                    }
                    .position(stop.point)
                }
            }
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }

    private func mapRoad(width: CGFloat, height: CGFloat, color: Color) -> some View {
        RoundedRectangle(cornerRadius: height / 2, style: .continuous)
            .fill(color)
            .frame(width: width, height: height)
    }

    private func routePreviewStops(width: CGFloat, height: CGFloat) -> [RoutePreviewStop] {
        [
            RoutePreviewStop(label: "Main Gate", point: CGPoint(x: width * 0.08, y: height * 0.65)),
            RoutePreviewStop(label: "Central Library", point: CGPoint(x: width * 0.52, y: height * 0.42)),
            RoutePreviewStop(label: "Sinchon Stn.", point: CGPoint(x: width * 0.92, y: height * 0.50))
        ]
    }

    private func fullRouteSection(for proposal: RouteProposal) -> some View {
        detailSection(title: "Full Route") {
            VStack(alignment: .leading, spacing: 12) {
                RequestTimelineRow(title: proposal.startPoint, subtitle: "1st floor")
                RequestTimelineRow(title: "Central Library", subtitle: "2nd floor")
                RequestTimelineRow(title: proposal.detailEndPoint, subtitle: "Bus stop")
            }
        }
    }

    private var commentsSection: some View {
        detailSection(title: "Student Comments") {
            VStack(spacing: 8) {
                CommentBubble(text: "This route would be really helpful on rainy days!")
                CommentBubble(text: "This route would be really helpful on rainy days!")

                HStack {
                    Text("Send your comments")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                    Spacer()
                    Image(systemName: "paperplane")
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(Color.backgroundGray)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private func benefitsSection(for proposal: RouteProposal) -> some View {
        detailSection(title: "Expected Benefits") {
            VStack(alignment: .leading, spacing: 7) {
                ForEach(proposal.displayBenefits, id: \.self) { benefit in
                    BenefitRow(text: benefit)
                }
            }
        }
    }

    private func statusSection(for proposal: RouteProposal) -> some View {
        detailSection(title: "Route Status") {
            VStack(alignment: .leading, spacing: 8) {
                StatusProgressRow(title: "Voting", isDone: true)
                StatusProgressRow(title: "Submitted", isDone: true)
                StatusProgressRow(title: "Under Review", isDone: proposal.status != .voting)
                StatusProgressRow(title: "Approved / Rejected", isDone: proposal.status == .operating)
                StatusProgressRow(title: "In Service", isDone: proposal.status == .operating)
            }
        }
    }

    private func supportersSection(for proposal: RouteProposal) -> some View {
        Text("\(proposal.voteCount.formatted()) Supporters")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func voteButton(for proposal: RouteProposal) -> some View {
        Button {
            viewModel.voteRouteProposal(routeID: proposal.id)
        } label: {
            Label(
                proposal.hasVoted ? "Voted(\(proposal.voteCount.formatted()))" : "Vote(\(proposal.voteCount.formatted()))",
                systemImage: "hand.thumbsup"
            )
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(proposal.status == .voting && proposal.hasVoted == false ? Color.white : Color.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(proposal.status == .voting && proposal.hasVoted == false ? Color.primaryPurple : Color.lightGray)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(proposal.status != .voting || proposal.hasVoted)
    }

    private func detailSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.textPrimary)

            content()
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }
}

private struct RoutePreviewStop {
    let label: String
    let point: CGPoint
}

private struct RequestTimelineRow: View {
    var title: String
    var subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color.primaryPurple)
                .frame(width: 8, height: 8)
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}

private struct CommentBubble: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct BenefitRow: View {
    var text: String

    var body: some View {
        Label(text, systemImage: "checkmark.circle")
            .font(.system(size: 11))
            .foregroundStyle(Color.textSecondary)
    }
}

private struct StatusProgressRow: View {
    var title: String
    var isDone: Bool

    var body: some View {
        Label(title, systemImage: isDone ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 11))
            .foregroundStyle(isDone ? Color.primaryPurple : Color.textSecondary)
    }
}

private extension RouteProposal {
    var detailEndPoint: String {
        if endPoint.localizedCaseInsensitiveContains("Sinchon") {
            return "Sinchon Stn. Exit 3"
        }
        return endPoint
    }

    var displayBenefits: [String] {
        expectedBenefits.isEmpty ? ["Save commuting time", "Better access on rainy days"] : expectedBenefits
    }
}

private extension RouteStatus {
    var detailBadgeBackgroundColor: Color {
        switch self {
        case .voting:
            return Color.primaryPurple.opacity(0.10)
        case .reviewing:
            return Color(hex: "#FEF9C2")
        case .operating:
            return Color(hex: "#DCFCE7")
        }
    }

    var detailBadgeTextColor: Color {
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
