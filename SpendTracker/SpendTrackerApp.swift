import SwiftUI

@main
struct SpendTrackerApp: App {
    var body: some Scene {
        let accountsViewModel = AccountsViewModel(networkManager: NetworkManagerImpl())

        WindowGroup {
            ContentView(accountsViewModel: accountsViewModel)
        }
    }
}
