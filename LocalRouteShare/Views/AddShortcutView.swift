import SwiftUI

struct AddShortcutView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    private let embedsInNavigationStack: Bool

    @State private var startPoint = ""
    @State private var endPoint = ""
    @State private var routeDescription = ""
    @State private var localTips = ""
    @State private var estimatedMinutes = "05"
    @State private var selectedTags: Set<String> = ["Raining"]
    @State private var isShowingRecording = false
    @State private var recordingResult = RouteRecordingResult.empty

    private let tagOptions = ["Raining", "Hot", "Cold", "Indoors", "Accessible"]

    private var parsedTags: [String] {
        let tags = tagOptions.filter { selectedTags.contains($0) }
        return tags.isEmpty ? ["Raining"] : tags
    }

    private var hasRecording: Bool {
        recordingResult.routePoints.isEmpty == false || recordingResult.photoMarkers.isEmpty == false
    }

    private var isValid: Bool {
        startPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && endPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && routeDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private var submittedDescription: String {
        let trimmedDescription = routeDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTips = localTips.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedTips.isEmpty == false else { return trimmedDescription }
        return "\(trimmedDescription)\nTip: \(trimmedTips)"
    }

    private var manualEstimatedTime: String {
        let trimmed = estimatedMinutes.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return "5 min" }
        return trimmed.localizedCaseInsensitiveContains("min") ? trimmed : "\(trimmed) min"
    }

    init(embedsInNavigationStack: Bool = true) {
        self.embedsInNavigationStack = embedsInNavigationStack
    }

    @ViewBuilder
    var body: some View {
        if embedsInNavigationStack {
            NavigationStack {
                content
            }
        } else {
            content
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                VStack(spacing: 14) {
                    FormTextField(title: "From", placeholder: "e.g. Yonsei West Gate", text: $startPoint)
                    FormTextField(title: "To", placeholder: "e.g. Student Union Bldg.", text: $endPoint)
                }

                recordingCard

                FormTextEditor(
                    title: "Route Description",
                    placeholder: "e.g. The 3rd-floor elevators are usually faster. The skybridge may be closed on weekends.",
                    text: $routeDescription
                )

                FormTextEditor(
                    title: "Local Tips (Optional)",
                    placeholder: "e.g. The skybridge may be closed on weekends.",
                    text: $localTips
                )

                FormTextField(title: "Estimated Time", placeholder: "05 min", text: $estimatedMinutes)

                tagPicker
            }
            .padding(20)
            .padding(.bottom, 18)
        }
        .background(Color.backgroundGray.ignoresSafeArea())
        .navigationTitle("Register My Route")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") {
                    dismiss()
                }
                .foregroundStyle(Color.textSecondary)
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    viewModel.addShortcut(
                        startPoint: startPoint,
                        endPoint: endPoint,
                        routeDescription: submittedDescription,
                        tags: parsedTags,
                        estimatedTime: hasRecording ? formattedDurationText(recordingResult.recordedDuration) : manualEstimatedTime,
                        distance: formattedDistance(recordingResult.recordedDistance),
                        routePoints: recordingResult.routePoints,
                        photoMarkers: recordingResult.photoMarkers,
                        recordedDistance: recordingResult.recordedDistance,
                        recordedDuration: recordingResult.recordedDuration
                    )
                    dismiss()
                }
                .fontWeight(.bold)
                .disabled(isValid == false)
            }
        }
        .fullScreenCover(isPresented: $isShowingRecording) {
            RecordingMapView { result in
                recordingResult = result
            }
        }
    }

    private var recordingCard: some View {
        VStack(spacing: 14) {
            VStack(spacing: 8) {
                Image(systemName: hasRecording ? "checkmark.seal.fill" : "figure.walk.circle.fill")
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(Color.primaryPurple)
                    .frame(width: 68, height: 68)
                    .background(Color.primaryPurple.opacity(0.12))
                    .clipShape(Circle())

                Text(hasRecording ? "Route Recorded" : "Ready to record")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.textPrimary)

                Text(hasRecording ? "Your route and photo markers are attached." : "Record your route by taking pictures on the way.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)

            if hasRecording {
                RouteMapView(
                    routePoints: recordingResult.routePoints,
                    photoMarkers: recordingResult.photoMarkers,
                    currentLocation: nil
                )
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.borderGray, lineWidth: 1)
                )

                HStack(spacing: 10) {
                    RecordingSummaryPill(icon: "figure.walk", title: formattedDistance(recordingResult.recordedDistance))
                    RecordingSummaryPill(icon: "timer", title: formattedDurationText(recordingResult.recordedDuration))
                    RecordingSummaryPill(icon: "camera.fill", title: "\(recordingResult.photoMarkers.count) photos")
                }
            } else {
                HStack(spacing: 12) {
                    Text("Don't want to take photos?")
                    Button("Enter Manually") {}
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.textSecondary)
            }

            Button {
                isShowingRecording = true
            } label: {
                Label(hasRecording ? "Record Again" : "Start Record", systemImage: hasRecording ? "arrow.counterclockwise" : "record.circle.fill")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.primaryPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.borderGray.opacity(0.85), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.035), radius: 10, y: 4)
    }

    private var tagPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Best For")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tagOptions, id: \.self) { tag in
                        HashtagChip(title: tag, isSelected: selectedTags.contains(tag)) {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }
                    }
                }
            }
        }
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

private struct RecordingSummaryPill: View {
    var icon: String
    var title: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(title)
                .lineLimit(1)
        }
        .font(.caption.weight(.bold))
        .foregroundStyle(Color.textSecondary)
        .frame(maxWidth: .infinity)
        .frame(height: 34)
        .background(Color.backgroundGray)
        .clipShape(Capsule())
    }
}

private struct FormTextField: View {
    var title: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)

            TextField(placeholder, text: $text)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.borderGray, lineWidth: 1)
                )
        }
    }
}

private struct FormTextEditor: View {
    var title: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.textSecondary)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .font(.subheadline)
                    .padding(10)
                    .frame(minHeight: 132)
                    .scrollContentBackground(.hidden)

                if text.isEmpty {
                    Text(placeholder)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary.opacity(0.7))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.borderGray, lineWidth: 1)
            )
        }
    }
}
