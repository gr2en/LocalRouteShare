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
    @State private var commentText = ""
    @State private var studentComments = [
        "This route would be really helpful on rainy days!",
        "A shuttle here would make the commute much easier."
    ]

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
                        routeMap(for: proposal)
                        fullRouteSection(for: proposal)
                        detailSection(title: "Why Students Need This Route") {
                            Text(proposal.reason)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.textSecondary)
                                .lineSpacing(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
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
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.textSecondary)
                Text(proposal.detailEndPoint)
                    .lineLimit(1)
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(Color.textPrimary)

            HStack(spacing: 12) {
                Label(proposal.voteCount.formatted(), systemImage: "hand.thumbsup")
                    .foregroundStyle(Color.primaryPurple)
                Label("Andrew Lee", systemImage: "person.fill")
                Text(proposal.status.displayText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(proposal.status.detailBadgeTextColor)
                    .padding(.horizontal, 10)
                    .frame(height: 20)
                    .background(proposal.status.detailBadgeBackgroundColor)
                    .clipShape(Capsule())
            }
            .font(.system(size: 12))
            .foregroundStyle(Color.textSecondary)
        }
    }

    private func routeMap(for proposal: RouteProposal) -> some View {
        RouteMapView(
            routePoints: proposal.detailRoutePoints,
            photoMarkers: proposal.detailMapMarkers,
            currentLocation: nil
        )
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
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
                ForEach(Array(studentComments.enumerated()), id: \.offset) { _, comment in
                    CommentBubble(text: comment)
                }

                HStack {
                    TextField("Send your comments", text: $commentText)
                        .font(.system(size: 12))
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.send)
                        .onSubmit(addComment)

                    Spacer()

                    Button(action: addComment) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.textSecondary : Color.primaryPurple)
                    }
                    .buttonStyle(.plain)
                    .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 12)
                .frame(height: 34)
                .background(Color.backgroundGray)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private func addComment() {
        let trimmedComment = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedComment.isEmpty == false else { return }

        studentComments.append(trimmedComment)
        commentText = ""
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
            .font(.system(size: 14, weight: .bold))
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
            .font(.system(size: 14, weight: .bold))
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
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.textPrimary)

            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }
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
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}

private struct CommentBubble: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12))
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
            .font(.system(size: 12))
            .foregroundStyle(Color.textSecondary)
    }
}

private struct StatusProgressRow: View {
    var title: String
    var isDone: Bool

    var body: some View {
        Label(title, systemImage: isDone ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 12))
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

    var detailRoutePoints: [RoutePoint] {
        if startPoint.localizedCaseInsensitiveContains("Yonsei")
            || endPoint.localizedCaseInsensitiveContains("Sinchon") {
            return [
                RoutePoint(latitude: 37.5659, longitude: 126.9380),
                RoutePoint(latitude: 37.5651, longitude: 126.9389),
                RoutePoint(latitude: 37.5645, longitude: 126.9403),
                RoutePoint(latitude: 37.5639, longitude: 126.9418),
                RoutePoint(latitude: 37.5632, longitude: 126.9436),
                RoutePoint(latitude: 37.5627, longitude: 126.9453)
            ]
        }

        return [
            RoutePoint(latitude: 37.5667, longitude: 126.9358),
            RoutePoint(latitude: 37.5661, longitude: 126.9366),
            RoutePoint(latitude: 37.5655, longitude: 126.9375)
        ]
    }

    var detailMapMarkers: [RoutePhotoMarker] {
        guard detailRoutePoints.isEmpty == false else { return [] }

        return [
            RoutePhotoMarker(
                latitude: detailRoutePoints.first?.latitude ?? 37.5659,
                longitude: detailRoutePoints.first?.longitude ?? 126.9380,
                imageData: nil,
                memo: startPoint
            ),
            RoutePhotoMarker(
                latitude: detailRoutePoints.last?.latitude ?? 37.5627,
                longitude: detailRoutePoints.last?.longitude ?? 126.9453,
                imageData: nil,
                memo: detailEndPoint
            )
        ]
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
