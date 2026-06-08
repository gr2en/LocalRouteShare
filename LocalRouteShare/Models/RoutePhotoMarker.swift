import Foundation

struct RoutePhotoMarker: Identifiable, Equatable {
    let id: UUID
    var latitude: Double
    var longitude: Double
    var imageData: Data?
    var imageName: String?
    var memo: String?
    var timestamp: Date

    init(
        id: UUID = UUID(),
        latitude: Double,
        longitude: Double,
        imageData: Data?,
        imageName: String? = nil,
        memo: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.imageData = imageData
        self.imageName = imageName
        self.memo = memo
        self.timestamp = timestamp
    }
}
