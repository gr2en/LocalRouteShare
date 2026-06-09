import SwiftUI
import UIKit

struct ShortcutDetailView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isShowingEdit = false
    @State private var isConfirmingDelete = false

    let shortcutID: UUID

    private var shortcut: Shortcut? {
        viewModel.shortcuts.first { $0.id == shortcutID }
    }

    var body: some View {
        Group {
            if let shortcut {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        headerCard(for: shortcut)
                        mapSection(for: shortcut)
                        routeInfoSection(for: shortcut)
                        bestForSection(for: shortcut)
                        localTipsSection(for: shortcut)
                        routeRatingSection(for: shortcut)
                        saveButton(for: shortcut)
                        photoSection(for: shortcut)
                    }
                    .padding(20)
                    .padding(.bottom, 18)
                }
            } else {
                missingShortcutState
            }
        }
        .background(Color.backgroundGray.ignoresSafeArea())
        .navigationTitle("Route Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let shortcut, canManage(shortcut) {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            isShowingEdit = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            isConfirmingDelete = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingEdit) {
            if let shortcut {
                EditShortcutView(shortcut: shortcut)
                    .environmentObject(viewModel)
            }
        }
        .alert("Delete Shortcut?", isPresented: $isConfirmingDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteShortcut(shortcutID: shortcutID)
                dismiss()
            }
        } message: {
            Text("This removes the shortcut from your shared routes. The action cannot be undone.")
        }
    }

    private func headerCard(for shortcut: Shortcut) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(shortcut.detailTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(2)

            HStack(spacing: 14) {
                Label(String(format: "%.1f (%d)", shortcut.rating, shortcut.ratingCount), systemImage: "star.fill")
                    .foregroundStyle(Color(hex: "#F0B100"))
                Label(shortcut.author, systemImage: "person.fill")
                Button {
                    viewModel.toggleSaveShortcut(shortcutID: shortcut.id)
                } label: {
                    Label(
                        shortcut.saveCount.formatted(),
                        systemImage: shortcut.isSaved ? "heart.fill" : "heart"
                    )
                    .foregroundStyle(shortcut.isSaved ? Color(hex: "#FF5A1F") : Color.textSecondary)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(shortcut.isSaved ? "Unlike shortcut" : "Like shortcut")
                .accessibilityValue("\(shortcut.saveCount.formatted()) likes")
                .accessibilityAddTraits(shortcut.isSaved ? .isSelected : [])
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(Color.textSecondary)

            HStack(spacing: 10) {
                DetailMetricCard(icon: "clock", title: "Time", value: displayedDuration(for: shortcut))
                DetailMetricCard(icon: "location", title: "Distance", value: displayedDistance(for: shortcut))
            }
        }
    }

    private func mapSection(for shortcut: Shortcut) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if hasMapContent(shortcut) {
                RouteMapView(
                    routePoints: shortcut.routePoints,
                    photoMarkers: shortcut.photoMarkers,
                    currentLocation: nil
                )
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.borderGray, lineWidth: 1)
                )
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "location.slash")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.textSecondary)

                    Text("No saved GPS route yet.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.borderGray, lineWidth: 1)
                )
            }
        }
    }

    private func routeInfoSection(for shortcut: Shortcut) -> some View {
        let stops = shortcut.displayRouteStops

        return VStack(alignment: .leading, spacing: 12) {
            Text("Full Route")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.textPrimary)

            VStack(spacing: 0) {
                ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                    RouteEndpointRow(
                        icon: routeStopIcon(at: index, totalCount: stops.count),
                        title: stop.title,
                        value: stop.detail,
                        tint: routeStopTint(at: index)
                    )

                    if index < stops.count - 1 {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .padding(.vertical, 6)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
    }

    private func bestForSection(for shortcut: Shortcut) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Best For")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.textPrimary)

            HStack(spacing: 8) {
                ForEach(shortcut.detailTags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 9)
                        .frame(height: 24)
                        .background(Color.lightGray)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }

    private func localTipsSection(for shortcut: Shortcut) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Local Tips")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.textPrimary)

            Text("A bit longer, but much more comfortable on hot days. Avoid the hills and use elevators instead.")
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }

    private func routeRatingSection(for shortcut: Shortcut) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How Was This Route?")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.textPrimary)

            HStack(spacing: 14) {
                Image("RouteMascot")
                    .renderingMode(.original)
                    .resizable()
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
                    .frame(width: 70, height: 78)

                Text("Rate This Route!")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 14)
                    .frame(height: 36)
                    .background(Color.lightGray)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { score in
                    Button {
                        viewModel.rateShortcut(shortcutID: shortcut.id, score: score)
                    } label: {
                        Image(systemName: score <= (shortcut.userRating ?? 0) ? "star.fill" : "star")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(score <= (shortcut.userRating ?? 0) ? Color(hex: "#F0B100") : Color.textSecondary.opacity(0.55))
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(score) star rating")
                    .accessibilityAddTraits(score <= (shortcut.userRating ?? 0) ? .isSelected : [])
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func photoSection(for shortcut: Shortcut) -> some View {
        if shortcut.photoMarkers.isEmpty == false {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "Photo Markers", subtitle: "\(shortcut.photoMarkers.count) saved locations")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(shortcut.photoMarkers) { marker in
                            RoutePhotoPreview(marker: marker)
                        }
                    }
                }
            }
        }
    }

    private func saveButton(for shortcut: Shortcut) -> some View {
        Button {
        } label: {
            Label(
                "Start Route",
                systemImage: "location.fill"
            )
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.primaryPurple)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var missingShortcutState: some View {
        VStack(spacing: 12) {
            Image(systemName: "map")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.textSecondary)

            Text("Route not found.")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func hasMapContent(_ shortcut: Shortcut) -> Bool {
        shortcut.routePoints.isEmpty == false || shortcut.photoMarkers.isEmpty == false
    }

    private func routeStopIcon(at index: Int, totalCount: Int) -> String {
        index == totalCount - 1 ? "mappin.circle.fill" : "circle.fill"
    }

    private func routeStopTint(at index: Int) -> Color {
        index == 0 ? .buttonBlue : .primaryPurple
    }

    private func canManage(_ shortcut: Shortcut) -> Bool {
        shortcut.author == viewModel.userProfile.nickname
    }

    private func displayedDistance(for shortcut: Shortcut) -> String {
        if shortcut.recordedDistance > 0 {
            return formattedDistance(shortcut.recordedDistance)
        }
        return shortcut.distance
    }

    private func displayedDuration(for shortcut: Shortcut) -> String {
        if shortcut.recordedDuration > 0 {
            return formattedDurationText(shortcut.recordedDuration)
        }
        return shortcut.estimatedTime
    }

    private func formattedDistance(_ distance: Double) -> String {
        if distance >= 1000 {
            return String(format: "%.2fkm", distance / 1000)
        }
        return "\(Int(distance.rounded()))m"
    }

    private func formattedDurationText(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        if minutes == 0 {
            return "\(seconds) sec"
        }
        if seconds == 0 {
            return "\(minutes) min"
        }
        return "\(minutes) min \(seconds) sec"
    }
}

private struct DetailMetricCard: View {
    var icon: String
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.textSecondary)

            Text(value)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct RouteEndpointRow: View {
    var icon: String
    var title: String
    var value: String
    var tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.10))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.textPrimary)

                Text(value)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

private extension Shortcut {
    var detailTitle: String {
        if title.localizedCaseInsensitiveContains("Engineering") {
            return "Eng. Hall A → Science Hall"
        }
        return title
            .replacingOccurrences(of: " -> ", with: " → ")
            .replacingOccurrences(of: "->", with: "→")
    }

    var detailTags: [String] {
        ["Raining", "Indoor Route", "Elevator"]
    }
}

private struct RoutePhotoPreview: View {
    var marker: RoutePhotoMarker

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            preview
                .frame(width: 132, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(marker.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var preview: some View {
        if let imageData = marker.imageData,
           let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                Color.backgroundGray
                Image(systemName: "camera.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}
