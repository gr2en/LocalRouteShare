import Foundation

struct Shortcut: Identifiable, Equatable {
    let id: UUID
    var title: String
    var author: String
    var startPoint: String
    var endPoint: String
    var routeDescription: String
    var localTips: String
    var tags: [String]
    var estimatedTime: String
    var distance: String
    var rating: Double
    var ratingCount: Int
    var userRating: Int?
    var saveCount: Int
    var isSaved: Bool
    var routeStops: [RouteStop]
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
        localTips: String = "",
        tags: [String],
        estimatedTime: String,
        distance: String,
        rating: Double,
        ratingCount: Int,
        userRating: Int? = nil,
        saveCount: Int,
        isSaved: Bool,
        routeStops: [RouteStop] = [],
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
        self.localTips = localTips
        self.tags = tags
        self.estimatedTime = estimatedTime
        self.distance = distance
        self.rating = rating
        self.ratingCount = ratingCount
        self.userRating = userRating
        self.saveCount = saveCount
        self.isSaved = isSaved
        self.routeStops = routeStops
        self.routePoints = routePoints
        self.photoMarkers = photoMarkers
        self.recordedDistance = recordedDistance
        self.recordedDuration = recordedDuration
    }
}

extension Shortcut {
    var displayLocalTips: String {
        let trimmedTips = localTips.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTips.isEmpty == false {
            return trimmedTips
        }

        if let legacyTipRange = routeDescription.range(of: "\nTip:", options: .caseInsensitive) {
            return routeDescription[legacyTipRange.upperBound...]
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return ""
    }

    var displayRouteStops: [RouteStop] {
        let cleanedStops = routeStops
            .map { stop in
                RouteStop(
                    id: stop.id,
                    title: stop.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    detail: stop.detail.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            .filter { $0.title.isEmpty == false }

        if cleanedStops.isEmpty == false {
            return cleanedStops
        }

        return [
            RouteStop(title: startPoint, detail: "Start"),
            RouteStop(title: endPoint, detail: "Destination")
        ]
    }
}
