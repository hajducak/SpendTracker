import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel

    var body: some View {
        VStack {
            if let accountDetail = viewModel.accountDetail {
                VStack(alignment: .leading) {
                    Text("IBAN: \(accountDetail.iban)")
                    Text("Name: \(accountDetail.name)")
                    Text("Currency: \(accountDetail.currency)")
                    Text("Product: \(accountDetail.product)")
                    Text("Status: \(accountDetail.status)")
                    Text("BIC: \(accountDetail.bic)")
                    Text("Account Type: \(accountDetail.cashAccountType)")
                    Text("Usage: \(accountDetail.usage)")
                }
                .padding()
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                Text("Loading details...")
                    .padding()
            }
        }
        .navigationTitle("Account Details")
    }
}
