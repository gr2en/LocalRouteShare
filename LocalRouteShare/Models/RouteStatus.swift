import SwiftUI

enum RouteStatus: String, CaseIterable, Codable {
    case voting
    case reviewing
    case operating

    var displayText: String {
        switch self {
        case .voting:
            return "Voting"
        case .reviewing:
            return "Under Review"
        case .operating:
            return "In Service"
        }
    }

    var tintColor: Color {
        switch self {
        case .voting:
            return .primaryPurple
        case .reviewing:
            return .buttonBlue
        case .operating:
            return Color(hex: "#10B981")
        }
    }
}
