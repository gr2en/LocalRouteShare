import Foundation

struct Shortcut: Identifiable, Equatable {
    let id: UUID
    var title: String
    var author: String
    var startPoint: String
    var endPoint: String
    var routeDescription: String
    var tags: [String]
    var estimatedTime: String
    var distance: String
    var rating: Double
    var ratingCount: Int
    var saveCount: Int
    var isSaved: Bool
    var routePoints: [RoutePoint]
    var photoMarkers: [RoutePhotoMarker]
    var recordedDistance: Double
    var recordedDuration: TimeInterval

    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        startPoint: String,
        endPoint: String,
        routeDescription: String,
        tags: [String],
        estimatedTime: String,
        distance: String,
        rating: Double,
        ratingCount: Int,
        saveCount: Int,
        isSaved: Bool,
        routePoints: [RoutePoint] = [],
        photoMarkers: [RoutePhotoMarker] = [],
        recordedDistance: Double = 0,
        recordedDuration: TimeInterval = 0
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.routeDescription = routeDescription
        self.tags = tags
        self.estimatedTime = estimatedTime
        self.distance = distance
        self.rating = rating
        self.ratingCount = ratingCount
        self.saveCount = saveCount
        self.isSaved = isSaved
        self.routePoints = routePoints
        self.photoMarkers = photoMarkers
        self.recordedDistance = recordedDistance
        self.recordedDuration = recordedDuration
    }
}
