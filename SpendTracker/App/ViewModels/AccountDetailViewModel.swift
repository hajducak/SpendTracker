import Foundation
import Combine

class AccountDetailViewModel: ObservableObject {
    @Published var accountDetail: AccountDetail?
    @Published var balances: [AccountBalance] = []
    @Published var transactions: [Transaction] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables: Set<AnyCancellable> = []
    private let networkManager: NetworkManagerProtocol
    private let accountViewModel: AccountViewModel

    init(networkManager: NetworkManagerProtocol, accountViewModel: AccountViewModel) {
        self.networkManager = networkManager
        self.accountViewModel = accountViewModel
        
        loadAccountDetail()
    }
    
    func loadAccountDetail() {
        guard let token = accountViewModel.token else {
            // Get token or what ?
            return
        }
        loadAccountDetails(token: token, resourceId: accountViewModel.resourceId)
    }
    
    func loadAccountDetails(token: String, resourceId: String) {
        isLoading = true
        errorMessage = nil
        let accountInfoPublisher = networkManager.getAccountDetails(token: token, resourceId: accountViewModel.resourceId)
        let balancesPublisher = networkManager.getAccountBalances(token: token, resourceId: resourceId)
        let transactionsPublisher = networkManager.getAccountTransactions(token: token, resourceId: resourceId)

        Publishers.Zip3(accountInfoPublisher, balancesPublisher, transactionsPublisher)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = "Chyba: \(error.localizedDescription)"
                }
            }, receiveValue: { accountResponse, balancesResponse, transactionsResponse in
                self.accountDetail = accountResponse.account
                self.balances = balancesResponse.balances
                self.transactions = (transactionsResponse.transactions.booked) ?? [] +
                (transactionsResponse.transactions.pending ?? [])
            })
            .store(in: &cancellables)
    }
}
