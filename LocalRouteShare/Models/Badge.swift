import Foundation

struct Badge: Identifiable, Equatable {
    let id: UUID
    var emoji: String
    var title: String
    var subtitle: String
    var isUnlocked: Bool

    init(id: UUID = UUID(), emoji: String, title: String, subtitle: String, isUnlocked: Bool) {
        self.id = id
        self.emoji = emoji
        self.title = title
        self.subtitle = subtitle
        self.isUnlocked = isUnlocked
    }
}
