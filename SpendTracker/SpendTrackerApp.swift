import SwiftUI

@main
struct SpendTrackerApp: App {
    var body: some Scene {
        let accountViewModel = AccountViewModel(networkManager: NetworkManagerImpl())

        WindowGroup {
            ContentView(accountViewModel: accountViewModel)
        }
    }
}
