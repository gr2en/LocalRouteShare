import SwiftUI

@main
struct LocalRouteShareApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
        }
    }
}
