import SwiftUI

struct AccountView: View {
    @ObservedObject private var viewModel: AccountViewModel
    
    init(viewModel: AccountViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let walletId = viewModel.walletId, let walletSecret = viewModel.walletSecret {
                    Text("Wallet ID: \(walletId)")
                        .font(.subheadline)
                    Text("Wallet Secret: \(walletSecret)")
                        .font(.subheadline)
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
