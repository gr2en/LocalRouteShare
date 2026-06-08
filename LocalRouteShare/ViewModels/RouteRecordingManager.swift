import CoreLocation
import Foundation

final class RouteRecordingManager: NSObject, ObservableObject {
    @Published var currentLocation: CLLocation?
    @Published var routePoints: [RoutePoint] = []
    @Published var photoMarkers: [RoutePhotoMarker] = []
    @Published var isRecording = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var statusMessage = "Routes are recorded only while the app stays open."

    private let locationManager = CLLocationManager()
    private var timer: Timer?
    private var startDate: Date?
    private var shouldStartAfterPermission = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 5
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
        authorizationStatus = locationManager.authorizationStatus
    }

    var totalDistance: Double {
        guard routePoints.count > 1 else { return 0 }

        return zip(routePoints, routePoints.dropFirst()).reduce(0) { partialResult, pair in
            let previous = CLLocation(latitude: pair.0.latitude, longitude: pair.0.longitude)
            let next = CLLocation(latitude: pair.1.latitude, longitude: pair.1.longitude)
            return partialResult + next.distance(from: previous)
        }
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startRecording() {
        switch authorizationStatus {
        case .notDetermined:
            shouldStartAfterPermission = true
            requestPermission()
        case .authorizedAlways, .authorizedWhenInUse:
            beginRecording()
        case .denied, .restricted:
            statusMessage = "Location permission is required to record routes."
        @unknown default:
            statusMessage = "Unable to check the current location permission status."
        }
    }

    func stopRecording() {
        isRecording = false
        locationManager.stopUpdatingLocation()
        stopTimer()

        if let startDate {
            elapsedTime = Date().timeIntervalSince(startDate)
        }
    }

    func addPhotoMarker(imageData: Data?, memo: String? = nil) {
        guard let coordinate = currentLocation?.coordinate ?? routePoints.last.map({
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }) else {
            statusMessage = "Add a photo after your current location is available."
            return
        }

        let marker = RoutePhotoMarker(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            imageData: imageData,
            imageName: "route-photo-\(photoMarkers.count + 1)",
            memo: memo
        )
        photoMarkers.append(marker)
        statusMessage = "Photo marker saved at your current location."
    }

    func resetRecording() {
        stopRecording()
        routePoints = []
        photoMarkers = []
        currentLocation = nil
        elapsedTime = 0
        startDate = nil
        statusMessage = "Routes are recorded only while the app stays open."
    }

    func recordingResult() -> RouteRecordingResult {
        RouteRecordingResult(
            routePoints: routePoints,
            photoMarkers: photoMarkers,
            recordedDistance: totalDistance,
            recordedDuration: elapsedTime
        )
    }

    private func beginRecording() {
        guard isRecording == false else { return }

        if startDate == nil {
            startDate = Date()
        }

        isRecording = true
        statusMessage = "Recording the route with outdoor GPS signals."
        locationManager.startUpdatingLocation()
        startTimer()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let startDate = self.startDate else { return }
            self.elapsedTime = Date().timeIntervalSince(startDate)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension RouteRecordingManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            statusMessage = "Location permission granted."
            if shouldStartAfterPermission {
                shouldStartAfterPermission = false
                beginRecording()
            }
        case .denied, .restricted:
            shouldStartAfterPermission = false
            statusMessage = "Location permission is required to record routes."
        case .notDetermined:
            statusMessage = "Requesting location permission."
        @unknown default:
            statusMessage = "Unable to check the current location permission status."
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        guard location.horizontalAccuracy >= 0 else { return }

        if location.horizontalAccuracy > 25 {
            statusMessage = "GPS accuracy is low, so this point was skipped."
            return
        }

        currentLocation = location

        guard isRecording else { return }

        let newPoint = RoutePoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp
        )

        guard let lastPoint = routePoints.last else {
            routePoints.append(newPoint)
            return
        }

        let previousLocation = CLLocation(latitude: lastPoint.latitude, longitude: lastPoint.longitude)
        if location.distance(from: previousLocation) >= 5 {
            routePoints.append(newPoint)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        statusMessage = "Failed to get location updates: \(error.localizedDescription)"
    }
}
