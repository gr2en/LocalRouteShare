import SwiftUI

struct ShortcutListView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var searchText = ""
    @State private var selectedTag = "All"
    @State private var selectedListMode: ShortcutListMode = .all
    @State private var isShowingAddShortcut = false
    @State private var shortcutPath: [UUID] = []

    private let displayTags = ["Unavailable", "Uphill", "Scenic", "Shortcut"]
    private let tagAliases: [String: [String]] = [
        "Unavailable": ["Unavailable", "Step-free", "Accessible", "Elevator"],
        "Uphill": ["Uphill", "Fast", "Commute", "Morning"],
        "Scenic": ["Scenic", "Hot Weather"],
        "Shortcut": ["Shortcut", "Rainy Day", "Raining", "Indoor", "Indoors", "Fast"]
    ]

    private var filteredShortcuts: [Shortcut] {
        viewModel.shortcuts.filter { shortcut in
            let matchesSearch = searchText.isEmpty
            || shortcut.title.localizedCaseInsensitiveContains(searchText)
            || shortcut.routeDescription.localizedCaseInsensitiveContains(searchText)
            || shortcut.startPoint.localizedCaseInsensitiveContains(searchText)
            || shortcut.endPoint.localizedCaseInsensitiveContains(searchText)

            let tagCandidates = tagAliases[selectedTag] ?? [selectedTag]
            let matchesTag = selectedTag == "All"
            || shortcut.tags.contains { shortcutTag in
                tagCandidates.contains { candidate in
                    shortcutTag.localizedCaseInsensitiveCompare(candidate) == .orderedSame
                }
            }
            return matchesSearch && matchesTag
        }
    }

    private var displayedShortcuts: [Shortcut] {
        switch selectedListMode {
        case .all:
            return filteredShortcuts
        case .best:
            return filteredShortcuts.sorted { lhs, rhs in
                if lhs.saveCount != rhs.saveCount {
                    return lhs.saveCount > rhs.saveCount
                }

                if lhs.rating != rhs.rating {
                    return lhs.rating > rhs.rating
                }

                return lhs.ratingCount > rhs.ratingCount
            }
        }
    }

    var body: some View {
        NavigationStack(path: $shortcutPath) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("My Routes")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.textPrimary)

                        Text("Share your favorite campus routes!")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.textSecondary)
                    }

                    SearchBar(text: $searchText, placeholder: "Search Destination")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(displayTags, id: \.self) { tag in
                                HashtagChip(title: tag, isSelected: selectedTag == tag) {
                                    selectedTag = selectedTag == tag ? "All" : tag
                                }
                            }
                        }
                    }

                    Button {
                        isShowingAddShortcut = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "figure.walk")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 34, height: 34)
                                .background(Color.white.opacity(0.18))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Add Your Route")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color.white)

                                Text("Share a route that actually works")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.white.opacity(0.82))
                            }

                            Spacer()

                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 16)
                        .frame(height: 72)
                        .background(Color.buttonBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    ShortcutListModeControl(selectedMode: $selectedListMode)

                    HStack(spacing: 6) {
                        Image(systemName: selectedListMode.iconName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(selectedListMode.tintColor)

                        Text(selectedListMode.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.textPrimary)
                    }
                    .padding(.top, 2)

                    LazyVStack(spacing: 14) {
                        ForEach(displayedShortcuts) { shortcut in
                            MyRouteShortcutCard(
                                shortcut: shortcut,
                                onStart: {
                                    shortcutPath.append(shortcut.id)
                                },
                                onToggleSave: {
                                    viewModel.toggleSaveShortcut(shortcutID: shortcut.id)
                                }
                            )
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 18)
            }
            .background(Color.backgroundGray.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: viewModel.shortcuts.count) { _ in
                searchText = ""
                selectedTag = "All"
                selectedListMode = .all
            }
            .navigationDestination(for: UUID.self) { shortcutID in
                ShortcutDetailView(shortcutID: shortcutID)
                    .environmentObject(viewModel)
            }
            .navigationDestination(isPresented: $isShowingAddShortcut) {
                AddShortcutView(embedsInNavigationStack: false)
                    .environmentObject(viewModel)
            }
        }
    }
}

private enum ShortcutListMode: String, CaseIterable, Identifiable {
    case all = "All"
    case best = "Best"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All Shortcuts"
        case .best:
            return "Best Shortcuts This Week"
        }
    }

    var iconName: String {
        switch self {
        case .all:
            return "clock.arrow.circlepath"
        case .best:
            return "star.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .all:
            return Color.textSecondary
        case .best:
            return Color(hex: "#F0B100")
        }
    }
}

private struct ShortcutListModeControl: View {
    @Binding var selectedMode: ShortcutListMode

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ShortcutListMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.26, dampingFraction: 0.9)) {
                        selectedMode = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(selectedMode == mode ? Color.white : Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedMode == mode ? Color.primaryPurple : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.borderGray.opacity(0.95), lineWidth: 1)
        )
    }
}

private struct MyRouteShortcutCard: View {
    var shortcut: Shortcut
    var onStart: () -> Void
    var onToggleSave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(shortcut.myRoutesTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: "#D1D5DB"))
                            .frame(width: 24, height: 24)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(shortcut.author)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Color.textSecondary)

                            Text("2 days ago")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.textSecondary.opacity(0.82))
                        }
                    }
                }

                Spacer(minLength: 8)

                Menu {
                    Button("Share") {}
                    Button(shortcut.isSaved ? "Saved" : "Save", action: onToggleSave)
                    Button("Report", role: .destructive) {}
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 32, height: 32)
                }
            }

            Text(shortcut.routeDescription)
                .font(.system(size: 11))
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)

            HStack(spacing: 10) {
                ListMetric(icon: "clock", value: shortcut.compactEstimatedTime)
                ListMetric(icon: "location", value: shortcut.distance)
                ListMetric(icon: "star.fill", value: String(format: "%.1f (%d)", shortcut.rating, shortcut.ratingCount))
            }

            HStack(spacing: 8) {
                ForEach(shortcut.myRoutesTags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 8)
                        .frame(height: 24)
                        .background(Color.lightGray)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }

            HStack(spacing: 10) {
                Button(action: onToggleSave) {
                    HStack(spacing: 7) {
                        Image(systemName: shortcut.isSaved ? "heart.fill" : "heart")
                            .font(.system(size: 15, weight: .bold))

                        Text(shortcut.saveCount.formatted())
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(shortcut.isSaved ? Color(hex: "#FF5A1F") : Color.textSecondary)
                    .frame(minWidth: 72, minHeight: 38, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(shortcut.isSaved ? "Unlike shortcut" : "Like shortcut")
                .accessibilityValue("\(shortcut.saveCount.formatted()) likes")
                .accessibilityAddTraits(shortcut.isSaved ? .isSelected : [])

                Spacer()

                Button(action: onStart) {
                    Label("Start", systemImage: "location.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 150, height: 34)
                        .background(Color.buttonBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.borderGray.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
    }
}

private struct ListMetric: View {
    var icon: String
    var value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(value)
                .lineLimit(1)
        }
        .font(.system(size: 11))
        .foregroundStyle(Color.textSecondary)
    }
}

private extension Shortcut {
    var myRoutesTitle: String {
        if title.contains("→") || title.contains("->") {
            return title
                .replacingOccurrences(of: " -> ", with: " → ")
                .replacingOccurrences(of: "->", with: "→")
        }

        return "\(startPoint) → \(endPoint)"
    }

    var myRoutesTags: [String] {
        Array(tags.prefix(3))
    }

    var compactEstimatedTime: String {
        estimatedTime
            .replacingOccurrences(of: " min", with: "m")
            .replacingOccurrences(of: " sec", with: "s")
    }
}
