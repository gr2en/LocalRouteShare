import SwiftUI

enum MainTab: Hashable, CaseIterable {
    case home
    case shortcuts
    case vote
    case myPage

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .shortcuts:
            return "Shortcuts"
        case .vote:
            return "Vote"
        case .myPage:
            return "My"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house"
        case .shortcuts:
            return "figure.walk"
        case .vote:
            return "bus"
        case .myPage:
            return "person"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home:
            return "house.fill"
        case .shortcuts:
            return "figure.walk.circle.fill"
        case .vote:
            return "bus.fill"
        case .myPage:
            return "person.fill"
        }
    }
}

struct BottomTabLabel: View {
    var tab: MainTab
    var isSelected: Bool

    var body: some View {
        Label(tab.title, systemImage: isSelected ? tab.selectedIcon : tab.icon)
    }
}

struct AppBottomTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 8)
        .padding(.bottom, 6)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color.borderGray.opacity(0.75))
                .frame(height: 1),
            alignment: .top
        )
    }

    private func tabButton(_ tab: MainTab) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.84)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .frame(height: 24)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .foregroundStyle(isSelected ? Color.primaryPurple : Color.textSecondary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
