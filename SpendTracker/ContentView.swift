import SwiftUI

struct ContentView: View {
    @StateObject private var accountsViewModel: AccountsViewModel
    
    init(accountsViewModel: AccountsViewModel) {
        _accountsViewModel = StateObject(wrappedValue: accountsViewModel)
    }
    
    var body: some View {
        TabView {
            AccountView(viewModel: accountsViewModel)
                .tabItem {
                    Label("Account", systemImage: "person.circle.fill")
                }
            
            Text("Other Tab Content")
                .tabItem {
                    Label("Other", systemImage: "star.circle.fill")
                }
        }
    }
}
