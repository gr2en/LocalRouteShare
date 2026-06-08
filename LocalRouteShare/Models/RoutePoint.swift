import Foundation

struct RoutePoint: Identifiable, Equatable {
    let id: UUID
    var latitude: Double
    var longitude: Double
    var timestamp: Date

    init(id: UUID = UUID(), latitude: Double, longitude: Double, timestamp: Date = Date()) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
}
