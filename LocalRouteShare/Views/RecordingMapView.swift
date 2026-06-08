import CoreLocation
import SwiftUI
import UIKit

struct RecordingMapView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var manager = RouteRecordingManager()
    @State private var isShowingImagePicker = false

    var onFinish: (RouteRecordingResult) -> Void

    private var pickerSourceType: UIImagePickerController.SourceType {
        UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
    }

    var body: some View {
        ZStack {
            RouteMapView(
                routePoints: manager.routePoints,
                photoMarkers: manager.photoMarkers,
                currentLocation: manager.currentLocation?.coordinate,
                followsCurrentLocation: true
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 18)
                    .padding(.top, 16)

                Spacer()

                bottomPanel
                    .padding(.horizontal, 18)
                    .padding(.bottom, 18)
            }
        }
        .background(Color.backgroundGray.ignoresSafeArea())
        .onAppear {
            manager.startRecording()
        }
        .onDisappear {
            if manager.isRecording {
                manager.stopRecording()
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(sourceType: pickerSourceType) { image in
                let data = image.jpegData(compressionQuality: 0.78)
                manager.addPhotoMarker(imageData: data)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Recording Route")
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(Color.textPrimary)

                    Text("Keep the app open while recording")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Button {
                    manager.stopRecording()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 6) {
                Label(manager.statusMessage, systemImage: "location.fill")
                Label("GPS accuracy may drop inside buildings.", systemImage: "exclamationmark.triangle.fill")
                Label("Background recording is not included in this MVP.", systemImage: "moon.zzz.fill")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.textSecondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.75), lineWidth: 1)
        )
    }

    private var bottomPanel: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                RecordingMetric(title: "Duration", value: formattedDuration(manager.elapsedTime), icon: "timer")
                RecordingMetric(title: "Distance", value: formattedDistance(manager.totalDistance), icon: "figure.walk")
            }

            HStack(spacing: 10) {
                RecordingMetric(title: "Points", value: "\(manager.routePoints.count)", icon: "point.3.connected.trianglepath.dotted")
                RecordingMetric(title: "Photos", value: "\(manager.photoMarkers.count)", icon: "camera.fill")
            }

            HStack(spacing: 10) {
                Button {
                    isShowingImagePicker = true
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.primaryPurple)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primaryPurple.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    manager.stopRecording()
                    onFinish(manager.recordingResult())
                    dismiss()
                } label: {
                    Label("Finish Recording", systemImage: "stop.circle.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primaryPurple)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, y: 8)
    }

    private func formattedDistance(_ distance: Double) -> String {
        if distance >= 1000 {
            return String(format: "%.2fkm", distance / 1000)
        }
        return "\(Int(distance.rounded()))m"
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct RecordingMetric: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.textSecondary)

            Text(value)
                .font(.headline.weight(.heavy))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
