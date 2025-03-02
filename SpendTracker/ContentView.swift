import SwiftUI

struct ContentView: View {
    @StateObject private var accountViewModel: AccountViewModel
    
    init(accountViewModel: AccountViewModel) {
        _accountViewModel = StateObject(wrappedValue: accountViewModel)
    }
    
    var body: some View {
        TabView {
            AccountView(viewModel: accountViewModel)
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
