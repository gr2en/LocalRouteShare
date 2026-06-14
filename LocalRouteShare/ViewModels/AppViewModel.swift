import Foundation

final class AppViewModel: ObservableObject {
    // These published values are the shared app state used by all tabs.
    @Published var shortcuts: [Shortcut]
    @Published var routeProposals: [RouteProposal]
    @Published var userProfile: UserProfile

    init(
        shortcuts: [Shortcut] = SampleData.shortcuts,
        routeProposals: [RouteProposal] = SampleData.routeProposals,
        userProfile: UserProfile = SampleData.userProfile
    ) {
        self.shortcuts = shortcuts
        self.routeProposals = routeProposals
        self.userProfile = userProfile
    }

    func toggleSaveShortcut(shortcutID: UUID) {
        guard let index = shortcuts.firstIndex(where: { $0.id == shortcutID }) else { return }

        var updatedShortcut = shortcuts[index]
        updatedShortcut.isSaved.toggle()

        // Keep the visible like count and the profile summary in sync.
        if updatedShortcut.isSaved {
            updatedShortcut.saveCount += 1
            userProfile.receivedLikes += 1
        } else {
            updatedShortcut.saveCount = max(0, updatedShortcut.saveCount - 1)
            userProfile.receivedLikes = max(0, userProfile.receivedLikes - 1)
        }

        shortcuts[index] = updatedShortcut
    }

    func rateShortcut(shortcutID: UUID, score: Int) {
        guard (1...5).contains(score),
              let index = shortcuts.firstIndex(where: { $0.id == shortcutID }) else { return }

        var updatedShortcut = shortcuts[index]
        let previousRating = updatedShortcut.userRating
        let currentTotal = updatedShortcut.rating * Double(updatedShortcut.ratingCount)

        // Recalculate the average rating without storing every user's score.
        if previousRating == score {
            let nextCount = max(0, updatedShortcut.ratingCount - 1)
            let nextTotal = max(0, currentTotal - Double(score))

            updatedShortcut.ratingCount = nextCount
            updatedShortcut.rating = nextCount == 0 ? 0 : nextTotal / Double(nextCount)
            updatedShortcut.userRating = nil
        } else if let previousRating {
            let nextTotal = currentTotal - Double(previousRating) + Double(score)

            updatedShortcut.rating = updatedShortcut.ratingCount == 0 ? Double(score) : nextTotal / Double(updatedShortcut.ratingCount)
            updatedShortcut.userRating = score
        } else {
            let nextCount = updatedShortcut.ratingCount + 1
            let nextTotal = currentTotal + Double(score)

            updatedShortcut.ratingCount = nextCount
            updatedShortcut.rating = nextTotal / Double(nextCount)
            updatedShortcut.userRating = score
        }

        shortcuts[index] = updatedShortcut
    }

    func voteRouteProposal(routeID: UUID) {
        guard let index = routeProposals.firstIndex(where: { $0.id == routeID }) else { return }
        guard routeProposals[index].status == .voting else { return }

        // Voting is reversible, so a second tap restores the previous state.
        if routeProposals[index].hasVoted {
            routeProposals[index].voteCount = max(0, routeProposals[index].voteCount - 1)
            routeProposals[index].participantCount = max(0, routeProposals[index].participantCount - 1)
            routeProposals[index].hasVoted = false
            userProfile.votedRouteCount = max(0, userProfile.votedRouteCount - 1)
            userProfile.localScore = max(0, userProfile.localScore - 3)
            userProfile.weeklyIncrease = max(0, userProfile.weeklyIncrease - 3)
        } else {
            routeProposals[index].voteCount += 1
            routeProposals[index].participantCount += 1
            routeProposals[index].hasVoted = true
            userProfile.votedRouteCount += 1
            userProfile.localScore += 3
            userProfile.weeklyIncrease += 3
        }
    }

    func addShortcut(
        startPoint: String,
        endPoint: String,
        routeDescription: String,
        localTips: String = "",
        tags: [String],
        estimatedTime: String,
        distance: String,
        routeStops: [RouteStop] = [],
        routePoints: [RoutePoint] = [],
        photoMarkers: [RoutePhotoMarker] = [],
        recordedDistance: Double = 0,
        recordedDuration: TimeInterval = 0
    ) {
        let trimmedStart = startPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEnd = endPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = routeDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTips = localTips.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTime = estimatedTime.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDistance = distance.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedStart.isEmpty == false,
              trimmedEnd.isEmpty == false,
              trimmedDescription.isEmpty == false,
              trimmedTime.isEmpty == false,
              trimmedDistance.isEmpty == false else {
            return
        }

        // The new shortcut is inserted first so the "All" list behaves like a recent feed.
        // When Firebase is added, store createdAt, authorID, and related fields in the shortcuts collection.
        let shortcut = Shortcut(
            title: "\(trimmedStart) → \(trimmedEnd)",
            author: userProfile.nickname,
            startPoint: trimmedStart,
            endPoint: trimmedEnd,
            routeDescription: trimmedDescription,
            localTips: trimmedTips,
            tags: tags.isEmpty ? ["New Route"] : tags,
            estimatedTime: trimmedTime,
            distance: trimmedDistance,
            rating: 0.0,
            ratingCount: 0,
            saveCount: 0,
            isSaved: false,
            routeStops: routeStops,
            routePoints: routePoints,
            photoMarkers: photoMarkers,
            recordedDistance: recordedDistance,
            recordedDuration: recordedDuration
        )

        shortcuts.insert(shortcut, at: 0)
        userProfile.shortcutCount += 1
        userProfile.localScore += 10
        userProfile.weeklyIncrease += 10
    }

    func updateShortcut(
        shortcutID: UUID,
        startPoint: String,
        endPoint: String,
        routeDescription: String,
        localTips: String? = nil,
        tags: [String],
        estimatedTime: String,
        distance: String,
        routeStops: [RouteStop]
    ) {
        guard let index = shortcuts.firstIndex(where: { $0.id == shortcutID }) else { return }
        guard shortcuts[index].author == userProfile.nickname else { return }

        let trimmedStart = startPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEnd = endPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = routeDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTime = estimatedTime.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDistance = distance.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedStart.isEmpty == false,
              trimmedEnd.isEmpty == false,
              trimmedDescription.isEmpty == false,
              trimmedTime.isEmpty == false,
              trimmedDistance.isEmpty == false else {
            return
        }

        shortcuts[index].title = "\(trimmedStart) → \(trimmedEnd)"
        shortcuts[index].startPoint = trimmedStart
        shortcuts[index].endPoint = trimmedEnd
        shortcuts[index].routeDescription = trimmedDescription
        if let localTips {
            shortcuts[index].localTips = localTips.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        shortcuts[index].tags = tags.isEmpty ? ["New Route"] : tags
        shortcuts[index].estimatedTime = trimmedTime
        shortcuts[index].distance = trimmedDistance
        shortcuts[index].routeStops = routeStops
    }

    func deleteShortcut(shortcutID: UUID) {
        guard let index = shortcuts.firstIndex(where: { $0.id == shortcutID }) else { return }
        guard shortcuts[index].author == userProfile.nickname else { return }

        let removedShortcut = shortcuts.remove(at: index)
        userProfile.shortcutCount = max(0, userProfile.shortcutCount - 1)
        userProfile.receivedLikes = max(0, userProfile.receivedLikes - removedShortcut.saveCount)
        userProfile.localScore = max(0, userProfile.localScore - 10)
        userProfile.weeklyIncrease = max(0, userProfile.weeklyIncrease - 10)
    }

    func addRouteProposal(
        startPoint: String,
        endPoint: String,
        reason: String,
        expectedBenefits: [String] = []
    ) {
        let trimmedStart = startPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEnd = endPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBenefits = expectedBenefits
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        guard trimmedStart.isEmpty == false,
              trimmedEnd.isEmpty == false,
              trimmedReason.isEmpty == false else {
            return
        }

        // New proposals always start in the voting stage.
        // When Firebase is added, store status, createdAt, and proposerID in the routeProposals collection.
        let proposal = RouteProposal(
            startPoint: trimmedStart,
            endPoint: trimmedEnd,
            reason: trimmedReason,
            expectedBenefits: trimmedBenefits,
            voteCount: 0,
            participantCount: 0,
            status: .voting,
            hasVoted: false
        )

        routeProposals.insert(proposal, at: 0)
        userProfile.localScore += 5
        userProfile.weeklyIncrease += 5
    }
}
