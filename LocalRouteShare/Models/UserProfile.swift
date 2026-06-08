import Foundation

struct UserProfile: Equatable {
    var nickname: String
    var level: String
    var school: String
    var localScore: Int
    var weeklyIncrease: Int
    var shortcutCount: Int
    var votedRouteCount: Int
    var receivedLikes: Int
    var badges: [Badge]
}
