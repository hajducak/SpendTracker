import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else {
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
                }
                List {
                    Section(header: Text("Balance")) {
                        ForEach(viewModel.balances, id: \.balanceType) { balance in
                            Text("\(balance.balanceAmount.amount) \(balance.balanceAmount.currency)")
                        }
                    }
                    
                    Section(header: Text("Transactions")) {
                        ForEach(viewModel.transactions, id: \.transactionId) { transaction in
                            VStack(alignment: .leading) {
                                Text("\(transaction.transactionAmount.amount) \(transaction.transactionAmount.currency)").bold()
                                Text(transaction.creditorName ?? "Unknown")
                                Text("Date: \(transaction.bookingDate)")
                            }
                        }
                    }
                }
            }
            
        }
        .navigationTitle("Account Details")
    }
}
