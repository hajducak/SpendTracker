import SwiftUI

struct AccountView: View {
    @ObservedObject private var viewModel: AccountViewModel
    
    init(viewModel: AccountViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let accounts = viewModel.accounts {
                    List(accounts, id: \.resourceId) { account in
                        Text(account.iban)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Loading...")
                        .padding()
                }
            }
            .navigationTitle("Account")
        }
    }
}
