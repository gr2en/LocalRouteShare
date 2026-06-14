import SwiftUI

struct AddShortcutView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    private let embedsInNavigationStack: Bool

    @State private var startPoint = ""
    @State private var endPoint = ""
    @State private var startDetail = "1st floor"
    @State private var viaPoint = ""
    @State private var viaDetail = "2nd floor"
    @State private var endDetail = "2nd floor"
    @State private var routeDescription = ""
    @State private var localTips = ""
    @State private var estimatedTimeValue = "05"
    @State private var estimatedTimeUnit: EstimatedTimeUnit = .minutes
    @State private var selectedTags: Set<String> = ["Raining"]
    @State private var isShowingRecording = false
    @State private var isEnteringManually = false
    @State private var isRouteStopsExpanded = true
    @State private var isShowingViaStop = false
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
        // A route can be submitted either with GPS recording or a manual description.
        let hasRequiredRouteInput = hasRecording
        || routeDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false

        return startPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && endPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && hasRequiredRouteInput
    }

    private var submittedDescription: String {
        let trimmedDescription = routeDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedDescription.isEmpty ? "Recorded route with photo markers." : trimmedDescription
    }

    private var submittedRouteStops: [RouteStop] {
        let trimmedStart = startPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedVia = viaPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEnd = endPoint.trimmingCharacters(in: .whitespacesAndNewlines)

        // Start and destination are required; the via stop is added only when the user opens it.
        var stops = [
            RouteStop(title: trimmedStart, detail: routeStopDetail(startDetail, fallback: "Start"))
        ]

        if isShowingViaStop, trimmedVia.isEmpty == false {
            stops.append(RouteStop(title: trimmedVia, detail: routeStopDetail(viaDetail, fallback: "Stopover")))
        }

        stops.append(RouteStop(title: trimmedEnd, detail: routeStopDetail(endDetail, fallback: "Destination")))
        return stops.filter { $0.title.isEmpty == false }
    }

    private var manualEstimatedTime: String {
        EstimatedTimeUnit.formattedDuration(value: estimatedTimeValue, unit: estimatedTimeUnit)
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

                if isEnteringManually {
                    routeDescriptionEditor
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    recordingCard
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                }

                routeStopsEditor

                FormTextEditor(
                    title: "Local Tips (Optional)",
                    placeholder: "e.g. The skybridge may be closed on weekends.",
                    text: $localTips
                )

                EstimatedTimeInput(
                    title: "Estimated Time",
                    value: $estimatedTimeValue,
                    unit: $estimatedTimeUnit
                )

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
                        localTips: localTips,
                        tags: parsedTags,
                        estimatedTime: hasRecording ? formattedDurationText(recordingResult.recordedDuration) : manualEstimatedTime,
                        distance: formattedDistance(recordingResult.recordedDistance),
                        routeStops: submittedRouteStops,
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
            // The recording screen returns GPS points and photo markers after the user finishes.
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
                // Preview the recorded route before saving it to the shared shortcut list.
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

            if hasRecording == false {
                HStack(spacing: 8) {
                    Text("Don't want to take photos?")

                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                            isEnteringManually = true
                        }
                    } label: {
                        Text("Enter Manually")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.textPrimary)
                            .padding(.horizontal, 10)
                            .frame(height: 24)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.borderGray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.textSecondary)
            }
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

    private var routeDescriptionEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            FormTextEditor(
                title: "Route Description",
                placeholder: "e.g. The 3rd-floor elevators are usually faster.\nThe skybridge may be closed on weekends.",
                text: $routeDescription
            )

            HStack(spacing: 8) {
                Text("Want to take photos?")

                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                        isEnteringManually = false
                    }
                } label: {
                    Text("Back to Record")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, 10)
                        .frame(height: 24)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.borderGray, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(Color.textSecondary)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var routeStopsEditor: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.26, dampingFraction: 0.9)) {
                    isRouteStopsExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Full Route Details")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.textPrimary)

                        Text("Shown on the Route Detail screen.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.textSecondary.opacity(0.82))
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.textSecondary)
                        .rotationEffect(.degrees(isRouteStopsExpanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)

            if isRouteStopsExpanded {
                VStack(spacing: 12) {
                    Divider()
                        .padding(.vertical, 12)

                    FormTextField(title: "Start Detail", placeholder: "e.g. 1st floor", text: $startDetail)

                    if isShowingViaStop {
                        FormTextField(title: "Via", placeholder: "e.g. Student Union Elevator", text: $viaPoint)
                        FormTextField(title: "Via Detail", placeholder: "e.g. 4th floor", text: $viaDetail)

                        Button {
                            withAnimation(.spring(response: 0.26, dampingFraction: 0.9)) {
                                isShowingViaStop = false
                                viaPoint = ""
                                viaDetail = "2nd floor"
                            }
                        } label: {
                            Label("Remove Via", systemImage: "minus.circle")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            withAnimation(.spring(response: 0.26, dampingFraction: 0.9)) {
                                isShowingViaStop = true
                            }
                        } label: {
                            Label("Add Via", systemImage: "plus.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color.primaryPurple)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }

                    FormTextField(title: "Destination Detail", placeholder: "e.g. 2nd floor", text: $endDetail)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
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

    private func routeStopDetail(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
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

enum EstimatedTimeUnit: String, CaseIterable, Identifiable {
    case minutes
    case hours

    var id: String { rawValue }

    var label: String {
        switch self {
        case .minutes:
            return "mins"
        case .hours:
            return "hours"
        }
    }

    static func formattedDuration(value: String, unit: EstimatedTimeUnit) -> String {
        let trimmedValue = normalizedInput(value)
        guard trimmedValue.isEmpty == false else {
            return unit == .minutes ? "5 mins" : "1 hour"
        }

        let numericValue = Double(trimmedValue) ?? 0
        let displayValue = formattedNumber(numericValue)

        switch unit {
        case .minutes:
            return "\(displayValue) \(numericValue == 1 ? "min" : "mins")"
        case .hours:
            return "\(displayValue) \(numericValue == 1 ? "hour" : "hours")"
        }
    }

    static func parsed(_ text: String) -> (value: String, unit: EstimatedTimeUnit) {
        let lowercasedText = text.lowercased()
        let unit: EstimatedTimeUnit = lowercasedText.contains("hour") || lowercasedText.contains("hr")
        ? .hours
        : .minutes

        let values = numbers(in: text)
        guard let firstValue = values.first else {
            return (unit == .minutes ? "05" : "1", unit)
        }

        if unit == .minutes,
           lowercasedText.contains("sec"),
           values.count > 1 {
            return (formattedNumber(firstValue + values[1] / 60), unit)
        }

        return (formattedNumber(firstValue), unit)
    }

    static func convertedValue(_ value: String, from currentUnit: EstimatedTimeUnit, to nextUnit: EstimatedTimeUnit) -> String {
        guard currentUnit != nextUnit else { return value }

        let numericValue = Double(normalizedInput(value)) ?? 0
        let convertedValue: Double

        switch (currentUnit, nextUnit) {
        case (.minutes, .hours):
            convertedValue = numericValue / 60
        case (.hours, .minutes):
            convertedValue = numericValue * 60
        default:
            convertedValue = numericValue
        }

        return formattedNumber(convertedValue)
    }

    static func normalizedInput(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
    }

    private static func numbers(in text: String) -> [Double] {
        var values: [Double] = []
        var number = ""

        func appendCurrentNumber() {
            guard number.isEmpty == false else { return }
            values.append(Double(number) ?? 0)
            number = ""
        }

        for character in text {
            if character.isNumber || character == "." || character == "," {
                number.append(character == "," ? "." : character)
            } else {
                appendCurrentNumber()
            }
        }

        appendCurrentNumber()
        return values
    }

    private static func formattedNumber(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }

        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}

struct EstimatedTimeInput: View {
    var title: String
    @Binding var value: String
    @Binding var unit: EstimatedTimeUnit

    private var convertedUnit: Binding<EstimatedTimeUnit> {
        Binding {
            unit
        } set: { nextUnit in
            value = EstimatedTimeUnit.convertedValue(value, from: unit, to: nextUnit)
            unit = nextUnit
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.textSecondary)

                Spacer()

                Picker("Time Unit", selection: convertedUnit) {
                    ForEach(EstimatedTimeUnit.allCases) { unit in
                        Text(unit.label).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 148)
            }

            HStack(spacing: 10) {
                TextField(unit == .minutes ? "05" : "1", text: $value)
                    .font(.subheadline)
                    .keyboardType(.decimalPad)

                Text(unit.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
            }
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
