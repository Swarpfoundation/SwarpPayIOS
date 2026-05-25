import SwiftUI

@main
struct SWARPVouchersApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    appState.handle(url: url)
                }
        }
    }
}
