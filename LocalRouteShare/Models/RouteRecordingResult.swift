import Foundation

struct RouteRecordingResult: Equatable {
    var routePoints: [RoutePoint]
    var photoMarkers: [RoutePhotoMarker]
    var recordedDistance: Double
    var recordedDuration: TimeInterval

    static let empty = RouteRecordingResult(
        routePoints: [],
        photoMarkers: [],
        recordedDistance: 0,
        recordedDuration: 0
    )
}
