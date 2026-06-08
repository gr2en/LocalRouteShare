import Foundation

struct RouteProposal: Identifiable, Equatable {
    let id: UUID
    var startPoint: String
    var endPoint: String
    var reason: String
    var expectedBenefits: [String]
    var voteCount: Int
    var participantCount: Int
    var status: RouteStatus
    var hasVoted: Bool

    init(
        id: UUID = UUID(),
        startPoint: String,
        endPoint: String,
        reason: String,
        expectedBenefits: [String] = [],
        voteCount: Int,
        participantCount: Int,
        status: RouteStatus,
        hasVoted: Bool
    ) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.reason = reason
        self.expectedBenefits = expectedBenefits
        self.voteCount = voteCount
        self.participantCount = participantCount
        self.status = status
        self.hasVoted = hasVoted
    }
}
