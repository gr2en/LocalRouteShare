import CoreLocation
import MapKit
import SwiftUI
import UIKit

struct RouteMapView: UIViewRepresentable {
    var routePoints: [RoutePoint]
    var photoMarkers: [RoutePhotoMarker]
    var currentLocation: CLLocationCoordinate2D?
    var followsCurrentLocation: Bool = false

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.pointOfInterestFilter = .includingAll
        mapView.setRegion(defaultRegion, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Redraw the overlays each time SwiftUI sends updated route data.
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)

        let coordinates = routePoints.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }

        // The recorded GPS points are displayed as one continuous route line.
        if coordinates.count > 1 {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyline)
        }

        // Photo markers are shown as map annotations so users can remember key places.
        for marker in photoMarkers {
            let annotation = PhotoMarkerAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude),
                title: "Photo Marker",
                subtitle: marker.memo ?? marker.timestamp.formatted(date: .omitted, time: .shortened)
            )
            mapView.addAnnotation(annotation)
        }

        if let currentLocation {
            mapView.addAnnotation(
                CurrentLocationAnnotation(
                    coordinate: currentLocation,
                    title: "Current Location",
                    subtitle: "GPS recording point"
                )
            )
        }

        updateVisibleRegion(on: mapView, coordinates: coordinates)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private var defaultRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5658, longitude: 126.9386),
            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        )
    }

    private func updateVisibleRegion(on mapView: MKMapView, coordinates: [CLLocationCoordinate2D]) {
        if followsCurrentLocation, let currentLocation {
            // Recording mode keeps the map centered on the user's latest position.
            let region = MKCoordinateRegion(
                center: currentLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
            )
            mapView.setRegion(region, animated: true)
            return
        }

        var visibleCoordinates = coordinates
        visibleCoordinates.append(contentsOf: photoMarkers.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        })

        if visibleCoordinates.count == 1, let coordinate = visibleCoordinates.first {
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
            )
            mapView.setRegion(region, animated: true)
            return
        }

        guard visibleCoordinates.count > 1 else { return }

        // Fit the map to every route point and marker instead of using a fixed zoom.
        let mapPoints = visibleCoordinates.map(MKMapPoint.init)
        let rect = mapPoints.reduce(MKMapRect.null) { partialResult, point in
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 1, height: 1)
            return partialResult.union(pointRect)
        }

        mapView.setVisibleMapRect(
            rect,
            edgePadding: UIEdgeInsets(top: 60, left: 44, bottom: 60, right: 44),
            animated: true
        )
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }

            let renderer = MKPolylineRenderer(polyline: polyline)
            // Use the app's purple color to make user-recorded routes easy to recognize.
            renderer.strokeColor = UIColor(red: 0.38, green: 0.33, blue: 0.96, alpha: 1)
            renderer.lineWidth = 6
            renderer.lineJoin = .round
            renderer.lineCap = .round
            return renderer
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is CurrentLocationAnnotation {
                let identifier = "CurrentLocationAnnotation"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.annotation = annotation
                view.markerTintColor = UIColor(red: 0.18, green: 0.50, blue: 1, alpha: 1)
                view.glyphImage = UIImage(systemName: "location.fill")
                view.canShowCallout = true
                return view
            }

            if annotation is PhotoMarkerAnnotation {
                let identifier = "PhotoMarkerAnnotation"
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.annotation = annotation
                view.markerTintColor = UIColor(red: 0.98, green: 0.62, blue: 0.06, alpha: 1)
                view.glyphImage = UIImage(systemName: "camera.fill")
                view.canShowCallout = true
                return view
            }

            return nil
        }
    }
}

private final class CurrentLocationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}

private final class PhotoMarkerAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
