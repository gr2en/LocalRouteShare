import SwiftUI

struct EditShortcutView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    let shortcut: Shortcut

    @State private var startPoint: String
    @State private var endPoint: String
    @State private var startDetail: String
    @State private var viaPoint: String
    @State private var viaDetail: String
    @State private var endDetail: String
    @State private var routeDescription: String
    @State private var estimatedTimeValue: String
    @State private var estimatedTimeUnit: EstimatedTimeUnit
    @State private var distance: String
    @State private var selectedTags: Set<String>
    @State private var isRouteStopsExpanded = true
    @State private var isShowingViaStop: Bool

    private let baseTagOptions = ["Outdoor", "Fast", "Rainy Day", "Commute", "Walk", "Photo Log", "Fewer Steps", "Scenic", "Indoor", "Elevator", "Step-free", "Morning"]

    init(shortcut: Shortcut) {
        self.shortcut = shortcut
        let routeStops = shortcut.displayRouteStops
        let startStop = routeStops.first
        let endStop = routeStops.last
        let viaStop = routeStops.count > 2 ? routeStops[1] : nil
        _startPoint = State(initialValue: shortcut.startPoint)
        _endPoint = State(initialValue: shortcut.endPoint)
        _startDetail = State(initialValue: startStop?.detail ?? "Start")
        _viaPoint = State(initialValue: viaStop?.title ?? "")
        _viaDetail = State(initialValue: viaStop?.detail ?? "Stopover")
        _endDetail = State(initialValue: endStop?.detail ?? "Destination")
        _routeDescription = State(initialValue: shortcut.routeDescription)
        let parsedEstimatedTime = EstimatedTimeUnit.parsed(shortcut.estimatedTime)
        _estimatedTimeValue = State(initialValue: parsedEstimatedTime.value)
        _estimatedTimeUnit = State(initialValue: parsedEstimatedTime.unit)
        _distance = State(initialValue: shortcut.distance)
        _selectedTags = State(initialValue: Set(shortcut.tags))
        _isShowingViaStop = State(initialValue: viaStop != nil)
    }

    private var tagOptions: [String] {
        var options = baseTagOptions
        for tag in shortcut.tags where options.contains(tag) == false {
            options.append(tag)
        }
        return options
    }

    private var parsedTags: [String] {
        let tags = tagOptions.filter { selectedTags.contains($0) }
        return tags.isEmpty ? ["New Route"] : tags
    }

    private var isValid: Bool {
        startPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && endPoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && routeDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && estimatedTimeValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && distance.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private var submittedEstimatedTime: String {
        EstimatedTimeUnit.formattedDuration(value: estimatedTimeValue, unit: estimatedTimeUnit)
    }

    private var submittedRouteStops: [RouteStop] {
        let trimmedStart = startPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedVia = viaPoint.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEnd = endPoint.trimmingCharacters(in: .whitespacesAndNewlines)

        var stops = [
            RouteStop(title: trimmedStart, detail: routeStopDetail(startDetail, fallback: "Start"))
        ]

        if isShowingViaStop, trimmedVia.isEmpty == false {
            stops.append(RouteStop(title: trimmedVia, detail: routeStopDetail(viaDetail, fallback: "Stopover")))
        }

        stops.append(RouteStop(title: trimmedEnd, detail: routeStopDetail(endDetail, fallback: "Destination")))
        return stops.filter { $0.title.isEmpty == false }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Update the public route details. Your recorded GPS path and photo markers stay attached.")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.top, 4)

                    VStack(spacing: 14) {
                        EditShortcutTextField(title: "Start", placeholder: "e.g. Dorms", text: $startPoint)
                        EditShortcutTextField(title: "Destination", placeholder: "e.g. Engineering Building", text: $endPoint)
                    }

                    routeStopsEditor

                    EditShortcutTextEditor(title: "Local tip or description", placeholder: "Add helpful tips for walking this route", text: $routeDescription)

                    VStack(spacing: 14) {
                        EstimatedTimeInput(
                            title: "Estimated Time",
                            value: $estimatedTimeValue,
                            unit: $estimatedTimeUnit
                        )
                        EditShortcutTextField(title: "Distance", placeholder: "e.g. 410m", text: $distance)
                    }

                    tagPicker
                }
                .padding(20)
            }
            .background(Color.backgroundGray.ignoresSafeArea())
            .navigationTitle("Edit Shortcut")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateShortcut(
                            shortcutID: shortcut.id,
                            startPoint: startPoint,
                            endPoint: endPoint,
                            routeDescription: routeDescription,
                            tags: parsedTags,
                            estimatedTime: submittedEstimatedTime,
                            distance: distance,
                            routeStops: submittedRouteStops
                        )
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(isValid == false)
                }
            }
        }
    }

    private var tagPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Select Tags")
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

                        Text("Edit the rows shown on the Route Detail screen.")
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

                    EditShortcutTextField(title: "Start Detail", placeholder: "e.g. 1st floor", text: $startDetail)

                    if isShowingViaStop {
                        EditShortcutTextField(title: "Via", placeholder: "e.g. Student Union Elevator", text: $viaPoint)
                        EditShortcutTextField(title: "Via Detail", placeholder: "e.g. 4th floor", text: $viaDetail)

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

                    EditShortcutTextField(title: "Destination Detail", placeholder: "e.g. 2nd floor", text: $endDetail)
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

    private func routeStopDetail(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}

private struct EditShortcutTextField: View {
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

private struct EditShortcutTextEditor: View {
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
