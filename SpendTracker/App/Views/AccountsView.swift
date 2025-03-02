import SwiftUI

struct AccountsView: View {
    @ObservedObject private var viewModel: AccountsViewModel
    
    init(viewModel: AccountsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                switch viewModel.state {
                case .empty:
                    VStack {
                        Spacer()
                        Text("No data found")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
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
                case .content(let accounts):
                    List(Array(accounts.enumerated()), id: \.element.resourceId) { index, account in
                        NavigationLink(
                            destination: AccountDetailView(
                                viewModel: AccountDetailViewModel(
                                    networkManager: viewModel.networkManager,
                                    accountDetailContentDataFactory: AccountDetailContentDataFactoryImpl(),
                                    resourceId: account.resourceId
                                )
                            )
                        ) {
                            VStack(alignment: .leading) {
                                Text("Account #\(index + 1):")
                                    .font(.title3)
                                Text("IBAN: \(account.iban)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Accounts")
        }
    }
}
