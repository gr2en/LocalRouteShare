import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var selectedTab: MainTab

    init() {
        _selectedTab = State(initialValue: MainTab.initialTabFromLaunchArguments())

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.shadowColor = UIColor(Color.borderGray)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(MainTab.home)
                .tabItem {
                    BottomTabLabel(tab: .home, isSelected: selectedTab == .home)
                }

            ShortcutListView()
                .tag(MainTab.shortcuts)
                .tabItem {
                    BottomTabLabel(tab: .shortcuts, isSelected: selectedTab == .shortcuts)
                }

            RouteVoteView()
                .tag(MainTab.vote)
                .tabItem {
                    BottomTabLabel(tab: .vote, isSelected: selectedTab == .vote)
                }

            MyPageView()
                .tag(MainTab.myPage)
                .tabItem {
                    BottomTabLabel(tab: .myPage, isSelected: selectedTab == .myPage)
                }
        }
        .tint(Color.primaryPurple)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            AppBottomTabBar(selectedTab: $selectedTab)
        }
    }
}

private extension MainTab {
    static func initialTabFromLaunchArguments() -> MainTab {
        let arguments = ProcessInfo.processInfo.arguments
        guard let argumentIndex = arguments.firstIndex(of: "-initialTab"),
              arguments.indices.contains(argumentIndex + 1) else {
            return .home
        }

        switch arguments[argumentIndex + 1].lowercased() {
        case "shortcuts":
            return .shortcuts
        case "vote":
            return .vote
        case "my":
            return .myPage
        default:
            return .home
        }
    }
}
