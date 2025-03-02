import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel

    var body: some View {
        VStack(alignment: .leading) {
            switch viewModel.state {
            case .error(let error):
                VStack {
                    Spacer()
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                    Button {
                        viewModel.refreshData()
                    } label: {
                        Text("Refresh data")
                    }
                    Spacer()
                }
            case .loading:
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .content(let accountDataViewModel):
                let accountDetail = accountDataViewModel.accountDetail
                let balances = accountDataViewModel.balances
                let transactions = accountDataViewModel.transactions
                List {
                    Section(header: Text("Details")) {
                        VStack(alignment: .leading) {
                            Text("IBAN:").bold() + Text(" \(accountDetail.iban)")
                            Text("Name:").bold() + Text(" \(accountDetail.name)")
                            Text("Currency:").bold() + Text(" \(accountDetail.currency)")
                            Text("Product:").bold() + Text(" \(accountDetail.product)")
                            Text("Status:").bold() + Text(" \(accountDetail.status)")
                            Text("BIC:").bold() + Text(" \(accountDetail.bic)")
                            Text("Account Type:").bold() + Text(" \(accountDetail.cashAccountType)")
                            Text("Usage:").bold() + Text(" \(accountDetail.usage)")
                        }
                        .font(.title3)
                    }
                    Section(header: Text("Balance")) {
                        if balances.isEmpty {
                            Text("No data found")
                        } else {
                            ForEach(balances, id: \.id) { balance in
                                Text("\(balance.amount) \(balance.currency)")
                                    .font(.title2)
                            }
                        }
                    }
                    Section(header: Text("Transactions")) {
                        if transactions.isEmpty {
                            Text("No data found")
                        } else {
                            ForEach(transactions, id: \.id) { transaction in
                                VStack(alignment: .leading) {
                                    HStack(alignment: .top) {
                                        transaction.additionalInfo.map {
                                            Text($0)
                                                .font(.title3)
                                        }
                                        Spacer()
                                        Text("\(transaction.amount) \(transaction.currency)")
                                            .font(.title3)
                                            .foregroundColor(transaction.amountColor)
                                    }
                                    HStack(alignment: .bottom) {
                                        VStack(alignment: .leading) {
                                            Text("Creditor: \(transaction.creditorName) \(transaction.creditorIBAN)")
                                                .font(.caption)
                                            Text("Debtor: \(transaction.debtorName) \(transaction.debtorIBAN)")
                                                .font(.caption)
                                        }.foregroundColor(.gray)
                                        Spacer()
                                        Text("\(transaction.date)")
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }.navigationTitle("Account Detail")
    }
}
