import SwiftUI

struct EditShortcutView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    let shortcut: Shortcut

    @State private var startPoint: String
    @State private var endPoint: String
    @State private var routeDescription: String
    @State private var estimatedTime: String
    @State private var distance: String
    @State private var selectedTags: Set<String>

    private let baseTagOptions = ["Outdoor", "Fast", "Rainy Day", "Commute", "Walk", "Photo Log", "Fewer Steps", "Scenic", "Indoor", "Elevator", "Step-free", "Morning"]

    init(shortcut: Shortcut) {
        self.shortcut = shortcut
        _startPoint = State(initialValue: shortcut.startPoint)
        _endPoint = State(initialValue: shortcut.endPoint)
        _routeDescription = State(initialValue: shortcut.routeDescription)
        _estimatedTime = State(initialValue: shortcut.estimatedTime)
        _distance = State(initialValue: shortcut.distance)
        _selectedTags = State(initialValue: Set(shortcut.tags))
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
        && estimatedTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        && distance.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
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

                    EditShortcutTextEditor(title: "Local tip or description", placeholder: "Add helpful tips for walking this route", text: $routeDescription)

                    VStack(spacing: 14) {
                        EditShortcutTextField(title: "Estimated Time", placeholder: "e.g. 5 min", text: $estimatedTime)
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
                            estimatedTime: estimatedTime,
                            distance: distance
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
